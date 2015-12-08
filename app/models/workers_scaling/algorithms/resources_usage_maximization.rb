module WorkersScaling

  ##
  # Resources usage maximization algorithm will use all available
  # computational resources through entire experiment
  class ResourcesUsageMaximization < Algorithm

    def self.algorithm_name
      'Resources usage maximization'
    end

    def self.description
      'Method will use all available computational power through entire experiment.'
    end

    ##
    # Schedules maximum number of workers to all available infrastructures
    def schedule_workers
      LOGGER.debug 'Schedule maximum number of workers to all available infrastructures'
      @resources_interface.get_available_infrastructures.each do |infrastructure|
        LOGGER.debug "#{infrastructure.inspect}"
        @resources_interface.schedule_workers(Float::INFINITY, infrastructure)
      end
    end

    ##
    # Description at #schedule_workers
    def initial_deployment
      schedule_workers
    end

    ##
    # Description at #schedule_workers
    def experiment_status_check
      schedule_workers
    end

  end

end