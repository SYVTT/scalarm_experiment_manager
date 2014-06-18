require_relative '../pl_grid_scheduler_base'

module QcgScheduler

  class PlGridScheduler < PlGridSchedulerBase
    JOBID_RE = /.*jobId\s+=\s+(.+)$/
    STATE_RE = /.*Status:\s+(\w+).*/
    STATUS_DESCRIPTION_RE = /.*StatusDescription:\s+(.*)\n/
    STATUS_DESC_RE = /.*StatusDesc:\s+(.*)\n/

    def self.long_name
      'PL-Grid QosCosGrid'
    end

    def self.short_name
      'qcg'
    end

    def long_name
      self.class.long_name
    end

    def short_name
      self.class.short_name
    end

    def prepare_job_files(sm_uuid, params)
      IO.write("/tmp/scalarm_job_#{sm_uuid}.sh", prepare_job_executable)
      IO.write("/tmp/scalarm_job_#{sm_uuid}.qcg", prepare_job_descriptor(sm_uuid, params))
    end

    def prepare_job_descriptor(uuid, params)
      log_path = PlGridJob.log_path(uuid)
      <<-eos
#QCG executable=scalarm_job_#{uuid}.sh
#QCG argument=#{uuid}
#QCG output=#{log_path}.out
#QCG error=#{log_path}.err
#QCG stage-in-file=scalarm_job_#{uuid}.sh
#QCG stage-in-file=scalarm_simulation_manager_#{uuid}.zip
#QCG host=#{params['plgrid_host'] or 'zeus.cyfronet.pl'}
#QCG queue=#{PlGridJob.queue_for_minutes(params['time_limit'].to_i)}
#QCG walltime=#{self.class.minutes_to_walltime(params['time_limit'].to_i)}
#{params['nodes'].blank? ? '' : "#QCG nodes=#{params['nodes']}:#{params['ppn']}" }
#{params['grant_id'].blank? ? '' : "#QCG grant=#{params['grant_id']}" }
      eos
    end

    def self.minutes_to_walltime(minutes)
      hh, mm = minutes.divmod(60)
      dd, hh = hh.divmod(24)
      "P#{dd}DT#{hh}H#{mm}M"
    end

    def send_job_files(sm_uuid, scp)
      scp.upload! "/tmp/scalarm_simulation_manager_#{sm_uuid}.zip", '.'
      scp.upload! "/tmp/scalarm_job_#{sm_uuid}.sh", '.'
      scp.upload! "/tmp/scalarm_job_#{sm_uuid}.qcg", '.'
    end

    def submit_job(ssh, job)
      ssh.exec!("chmod a+x scalarm_job_#{job.sm_uuid}.sh")
      submit_job_output = ssh.exec!("qcg-sub scalarm_job_#{job.sm_uuid}.qcg")

      Rails.logger.debug("QCG output lines: #{submit_job_output}")

      submit_job_output and (job.job_id = QcgScheduler::PlGridScheduler.parse_job_id(submit_job_output))
    end

    def self.parse_job_id(submit_job_output)
      jobid_match = submit_job_output.match(JOBID_RE)
      jobid_match and jobid_match[1] or nil
    end

    # QCG Job states
    # UNSUBMITTED – task processing suspended because of queue dependencies
    # UNCOMMITED - task is waiting for processing confirmation
    # QUEUED – task is waiting in queue for processing
    # PREPROCESSING – system is preparing environment for task
    # PENDING – application waits for execution in queuing system in terms of job,
    # RUNNING – user's appliaction is running in terms of job,
    # STOPPED – application execution has been completed, but queuing system does not copied results and cleaned environment
    # POSTPROCESSING – queuing system ends job: copies result files, cleans environment, etc.
    # FINISHED – job has been completed
    # FAILED – error processing job
    # CANCELED – job has been cancelled by user

    STATES_MAPPING = {
        'UNSUBMITTED' => :initializing,
        'UNCOMMITED' => :initializing,
        'QUEUED' => :initializing,
        'PREPROCESSING' => :initializing,
        'PENDING' => :initializing,
        'RUNNING' => :running,
        'STOPPED' => :deactivated, # TODO: :running? it's probably not ready for fetching logs
        'POSTPROCESSING' => :deactivated,
        'FINISHED' => :deactivated,
        'FAILED' => :deactivated,
        'CANCELED' => :deactivated,
        'UNKNOWN' => :error
    }

    def status(ssh, job)
      STATES_MAPPING[qcg_state(ssh, job.job_id)] or :error
    end

    def qcg_state(ssh, job_id)
      QcgScheduler::PlGridScheduler.parse_qcg_state(get_job_info(ssh,job_id))
    end

    def qcg_status_desc(ssh, job_id)
      QcgScheduler::PlGridScheduler.parse_qcg_status_desc(get_job_info(ssh,job_id))
    end

    def self.parse_qcg_state(state_output)
      state_match = state_output.match(STATE_RE)
      if state_match
        state_match[1]
      else
        'UNKNOWN'
      end
    end

    def self.parse_qcg_status_desc(output)
      state_match = output.match(STATUS_DESC_RE)
      if state_match
        state_match[1]
      else
        nil
      end
    end

    def get_job_info(ssh, job_id)
      ssh.exec!("qcg-info #{job_id}")
    end

    def cancel(ssh, job)
      output = ssh.exec!("qcg-cancel #{job.job_id}")
      Rails.logger.debug("QCG cancel output:\n#{output}")
      output
    end

    def get_log(ssh, job)
      err_log = ssh.exec! "tail -25 #{job.log_path}.err"
      out_log = ssh.exec! "tail -25 #{job.log_path}.out"
      ssh.exec! "rm #{job.log_path}.err"
      ssh.exec! "rm #{job.log_path}.out"

      if qcg_state(ssh, job.job_id) == 'FAILED'
        <<-eos
--- QCG info ---
#{get_job_info(ssh, job.job_id)}
--- STDOUT ---
#{out_log}
--- STDERR ---
#{err_log}
        eos
      else
        <<-eos
--- STDOUT ---
#{out_log}
--- STDERR ---
#{err_log}
        eos
      end
    end

    def clean_after_job(ssh, job)
      super
      ssh.exec!("rm scalarm_job_#{job.sm_uuid}.qcg")
    end

    def self.available_hosts
      [
        'zeus.cyfronet.pl',
        'nova.wcss.wroc.pl',
        'galera.task.gda.pl',
        'reef.man.poznan.pl',
        'inula.man.poznan.pl',
        'hydra.icm.edu.pl',
        'moss.man.poznan.pl',
      ]
    end

  end

end