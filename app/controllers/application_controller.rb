require 'openid'

class ApplicationController < ActionController::Base
  include ScalarmAuthentication
  include ParameterValidation

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, :except => [:openid_callback_plgrid]

  before_filter :read_server_name
  before_filter :authenticate, :except => [:status, :login, :login_openid_google, :openid_callback_google,
                                           :login_openid_plgrid, :openid_callback_plgrid]
  before_filter :start_monitoring, except: [:status]
  after_filter :stop_monitoring, except: [:status]

  # due to security reasons (DISABLED)
  # after_filter :set_cache_buster

  rescue_from ValidationError, MissingParametersError, SecurityError, BSON::InvalidObjectId,
              with: :generic_exception_handler

  @@probe = MonitoringProbe.new


  protected

  def generic_exception_handler(exception)
    Rails.logger.warn("Exception caught in generic_exception_handler: #{exception.message}")
    Rails.logger.debug("Exception backtrace:\n#{exception.backtrace.join("\n")}")

    respond_to do |format|
      format.html do
        flash[:error] = exception.to_s
        redirect_to action: :index
      end

      format.json do
        render json: {
                        status: 'error',
                        reason: exception.to_s
                     },
               status: 412
      end

      format.js do
        @error_message = exception.to_s
        render partial: '/js_error_handler'
      end
    end
  end

  def authentication_failed
    Rails.logger.debug('[authentication] failed')
    respond_to do |format|
      format.html do
        Rails.logger.debug('[authentication] redirecting to login page')

        session[:original_url] = request.original_url
        #session[:intended_params] = params.to_hash.except('action', 'controller')

        keep_session_params(:server_name, :original_url) do
          reset_session
        end

        @user_session.destroy unless @user_session.nil?

        flash[:error] = t('login.required')

        redirect_to :login
      end

      format.json do
        Rails.logger.debug('[authentication] 403')

        render json: {status: 'error', reason: 'Authentication failed'}, status: :unauthorized
      end
    end

  end

  def start_monitoring
    #@probe = MonitoringProbe.new
    @action_start_time = Time.now
  end

  def stop_monitoring
    processing_time = ((Time.now - @action_start_time)*1000).to_i.round
    #Rails.logger.info("[monitoring][#{controller_name}][#{action_name}]#{processing_time}")
    @@probe.send_measurement(controller_name, action_name, processing_time)
  end

  def validate(validators)
    validate_params(params, validators)
  end

  def read_server_name
    session[:server_name] = params[:server_name] if params.include? :server_name
  end

  def keep_session_params(*args, &block)
    values = {}
    args.each do |param|
      values[param] = session[param] if session.include? param
    end
    begin
      yield block
    ensure
      values.each do |param, value|
        session[param] = value
      end
    end
  end

  # DEPRECATED due to security reasons
  #def set_cache_buster
    #response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    #response.headers["Pragma"] = "no-cache"
    #response.headers["Server"] = "Scalarm custom server"
    #
    #cookies.each do |key, value|
    #  response.delete_cookie(key)
    #  if value.kind_of?(Hash)
    #    response.set_cookie(key, value.merge!({expires: 6.hour.from_now}))
    #  else
    #    response.set_cookie(key, {value: value, expires: 6.hour.from_now})
    #  end
    #end
  #end

end
