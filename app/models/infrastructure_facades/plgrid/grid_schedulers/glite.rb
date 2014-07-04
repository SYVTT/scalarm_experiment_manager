require_relative '../pl_grid_scheduler_base'

module GliteScheduler

  class PlGridScheduler < PlGridSchedulerBase
    def initialize(logger)
      super(logger)
      @last_ssh = nil
    end

    def self.long_name
      'PL-Grid gLite'
    end

    def self.short_name
      'glite'
    end

    def long_name
      self.class.long_name
    end

    def short_name
      self.class.short_name
    end

    def prepare_job_files(sm_uuid, params)
      IO.write("/tmp/scalarm_job_#{sm_uuid}.sh", prepare_job_executable)
      IO.write("/tmp/scalarm_job_#{sm_uuid}.jdl", prepare_job_descriptor(sm_uuid))
    end

    def send_job_files(sm_uuid, scp)
      paths = [
          "/tmp/scalarm_simulation_manager_#{sm_uuid}.zip",
          "/tmp/scalarm_job_#{sm_uuid}.sh",
          "/tmp/scalarm_job_#{sm_uuid}.jdl"
      ]
      scp.upload_multiple! paths, '.'
    end

    def submit_job(ssh, job)
      ssh.exec!("chmod a+x scalarm_job_#{job.sm_uuid}.sh")
      #  schedule the job with glite wms
      submit_job_output = PlGridScheduler.execute_glite_command("glite-wms-job-submit -a scalarm_job_#{job.sm_uuid}.jdl", ssh)
      logger.debug("Glite submission output lines: #{submit_job_output}")

      submit_job_output ? (job.job_id = GliteScheduler::PlGridScheduler.parse_job_id(submit_job_output)) : nil
    end

    def self.parse_job_id(submit_job_output)
      match = submit_job_output.match /Your job identifier is:\s+(\S+)/
      match ? match[1] : nil
    end

    def glite_state(ssh, job)
      output = PlGridScheduler.execute_glite_command "glite-wms-job-status #{job.job_id}", ssh
      GliteScheduler::PlGridScheduler.parse_job_status(output)
    end

    def self.parse_job_status(state_output)
      match = state_output.match /Current Status:\s+(\S+)/
      match ? match[1] : nil
    end

    # --- gLite states:
    # Submitted -	The job has been submitted by the user but not yet processed by the RB
    # Waiting	- The job has been accepted by the RB but not yet matched to a CE
    # Ready	- The job has been assigned to a CE but not yet transferred to it
    # Scheduled	- The job is waiting in the local batch system queue on the CE
    # Running	- The job is running on a WN
    # Done(Success) - The job has finished successfully
    # Cleared - The Output Sandbox has been retrieved by the user

    STATES_MAPPING = {
        'Submitted' => :initializing,
        'Waiting' => :initializing,
        'Ready' => :initializing,
        'Scheduled' => :initializing,
        'Running' => :running,
        'Done(Success)' => :deactivated,
        'Cleared' => :deactivated
    }

    def status(ssh, job)
      STATES_MAPPING[glite_state(ssh, job)] or :error
    end

    def cancel(ssh, job)
      PlGridScheduler.execute_glite_command "glite-wms-job-cancel --no-int #{job.job_id}", ssh
    end

    def clean_after_job(ssh, job)
      super
      ssh.exec!("rm scalarm_job_#{job.sm_uuid}.jdl")
    end

    # wcss - "dwarf.wcss.wroc.pl:8443/cream-pbs-plgrid"
    # cyfronet - "cream.grid.cyf-kr.edu.pl:8443/cream-pbs-plgrid"
    # icm - "ce9.grid.icm.edu.pl:8443/cream-pbs-plgrid"
    # task - "cream.grid.task.gda.pl:8443/cream-pbs-plgrid"
    # pcss - "creamce.reef.man.poznan.pl:8443/cream-pbs-plgrid"
    def prepare_job_descriptor(uuid)
      log_path = PlGridJob.log_path(uuid)
      <<-eos
  Executable = "scalarm_job_#{uuid}.sh";
  Arguments = "#{uuid}";
  StdOutput = "#{log_path}";
  StdError = "#{log_path}";
  OutputSandbox = {"#{log_path}"};
  InputSandbox = {"scalarm_job_#{uuid}.sh", "scalarm_simulation_manager_#{uuid}.zip"};
  Requirements = (other.GlueCEUniqueID == "dwarf.wcss.wroc.pl:8443/cream-pbs-plgrid");
  VirtualOrganisation = "vo.plgrid.pl";
      eos
    end

    # Not used now
    # def new_session?(ssh)
    #   if @last_ssh.equal? ssh
    #     true
    #   else
    #     @last_ssh = ssh
    #     false
    #   end
    # end

    # Not used because of stateless SSH session usage
    # def prepare_session(ssh)
    #   if new_session?(ssh)
    #     logger.debug 'initializing proxy'
    #     voms_proxy_init(ssh, 'vo.plgrid.pl')
    #   end
    # end

    def get_log(ssh, job)
      output = PlGridScheduler.execute_glite_command("glite-wms-job-output --dir . #{job.job_id}", ssh)
      output_dir = GliteScheduler::PlGridScheduler.parse_get_output(output)
      ssh.exec!("tail -25 #{output_dir}/#{job.log_path}")
    end

    def self.parse_get_output(output)
      match = output.match /retrieved and stored in the directory:\s+(\S+)/
      match ? match[1] : nil
    end

    def self.execute_glite_command(command, ssh)
      # Before proxy init, force to use X509 default certificate and key (from UI storage)
      # Because by default it could use KeyFS storage
      cmd = "unset X509_USER_CERT; unset X509_USER_KEY; voms-proxy-init --voms vo.plgrid.pl; #{command}"
      begin
        result = nil
        timeout 10 do
          result = ssh.exec! cmd
        end
        raise StandardError.new 'voms-proxy-init: No credentials found!' if result =~ /No credentials found!/
        return result
      rescue Timeout::Error
        raise StandardError.new 'Timeout executing voms-proxy-init - probably key has passphrase'
      end
    end

  end

end