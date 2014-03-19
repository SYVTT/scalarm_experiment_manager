require_relative 'private_machines/scheduled_private_machine.rb'
require_relative 'shell_commands.rb'

class PrivateMachineFacade < InfrastructureFacade

  # prefix for all created and managed VMs
  VM_NAME_PREFIX = 'scalarm_'

  def initialize
    super()
  end

  # implements InfrastructureFacade
  def short_name
    'private_machine'
  end

  # implements InfrasctuctureFacade
  def current_state(user)
    # FIXME
    'Not available yet'
  end

  # implements InfrasctuctureFacade
  def monitoring_loop
    # TODO: use one ssh session per user@host:port (group)
    machine_records = PrivateMachineRecord.all.each do |record|
      Net::SSH.start(record.credentials.host, record.credentials.login,
                     password: record.credentials.secret_password) do |ssh|
        ScheduledPrivateMachine.new(record, ssh).monitor
      end
    end
  end

  # --

  # implements InfrasctuctureFacade
  # Params hash:
  # - 'private_machine_id' => id of PrivateMachineCredentials record - this machine will be initialized
  def start_simulation_managers(user, instances_count, experiment_id, params = {})
    logger.debug "Start simulation managers for experiment #{experiment_id}, additional params: #{params}"

    machine_creds = PrivateMachineCredentials.find_by_id(params['private_machine_id'])

    if machine_creds.nil?
      return 'error', I18n.t('infrastructure_facades.private_machine.unknown_machine_id')
    elsif machine_creds.user_id != user.id
      return 'error', I18n.t('infrastructure_facades.private_machine.no_permissions',
                             name: "#{params['login']}@#{params['host']}", scalarm_login: user.login)
    end

    PrivateMachineRecord.new({
        user_id: user.id,
        experiment_id: experiment_id,
        private_machine_id: private_machine_id,
        created_at: Time.now,
        time_limit: params['time_limit'],
        start_at: params['start_at'],
        sm_uuid: SecureRandom.uuid,
        sm_initialized: false
                             })
    ['ok', I18n.t('infrastructure_facades.private_machine.scheduled_info', count: sched_instances.size,
                        machine_name: machine_creds.machine_desc)]

  end

  # implements InfrasctuctureFacade
  def default_additional_params
    {}
  end

  #def stop_simulation_managers(user, instances_count, experiment = nil)
  #  raise 'not implemented'
  #end

  # implements InfrasctuctureFacade
  def get_running_simulation_managers(user, experiment = nil)
    CloudVmRecord.find_all_by_query('cloud_name'=>@short_name, 'user_id'=>user.id) do |instance|
      instance.to_s
    end
  end

  # implements InfrasctuctureFacade
  def add_credentials(user, params, session)
    credentials = CloudImageSecrets.new(
        'user_id'=>user.id,
        'host'=>params[:host],
        'ssh_port'=>params[:ssh_port],
        'login'=>params[:login]
    )
    credentials.secret_password = params[:secret_password]
    credentials.save
    'ok'
  end

  # implements InfrasctuctureFacade
  def clean_tmp_credentials(user_id, session)
  end


end
