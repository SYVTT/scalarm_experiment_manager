# Subclasses must implement:
# - short_name() -> String
# - long_name() -> String

require 'infrastructure_facades/plgrid/pl_grid_simulation_manager'

class PlGridSchedulerBase
  include SimulationManagersContainer

  def sm_record(resource_id, user_id)
    PlGridJob.find_by_query('scheduler_type'=>short_name, 'user_id'=>user_id, 'job_id'=>resource_id)
  end

  def all_sm_records_for(user_id)
    PlGridJob.find_all_by_query('scheduler_type'=>short_name, 'user_id'=>user_id)
  end

  def simulation_managers_for(user_id)
    jobs = all_sm_records_for(user_id)
    credentials = GridCredentials.find_by_user_id(user_id)
    if credentials.nil?
      []
    else
      jobs.map { |r| PlGridSimulationManager.new(r) }
    end
  end

  def simulation_manager(resource_id, user_id)
    job = sm_record(resource_id, user_id)
    credentials = GridCredentials.find_by_user_id(user_id)
    credentials.nil? ? nil : PlGridSimulationManager.new(job)
  end

end