require_dependency 'clouds/cloud_facade_factory'
require_dependency 'plgrid/pl_grid_facade_factory'

require_relative 'private_machine_facade'

class InfrastructureFacadeFactory

  def self.get_facade_for(infrastructure_name)
    raise InfrastructureErrors::NoSuchInfrastructureError.new(infrastructure_name) if infrastructure_name.nil?
    infrastructure_name = infrastructure_name.to_s

    facade =
        if PlGridFacadeFactory.instance.provider_names.include? infrastructure_name
          PlGridFacadeFactory.instance.get_facade(infrastructure_name)
        elsif CloudFacadeFactory.instance.provider_names.include? infrastructure_name
          CloudFacadeFactory.instance.get_facade(infrastructure_name)
        # elsif infrastructure_name == 'plgrid'
        #   # this is a hack for removing/adding credentials
        #   # because every PL-Grid queuing system uses the same credentials, default Q-system is used
        #   PlGridFacadeFactory.instance.get_facade('qsub')
        elsif infrastructure_name.start_with?('cluster_')
          ClusterFacadeFactory.instance.get_facade_for(infrastructure_name)
        else
          facade_class = InfrastructureFacadeFactory.other_infrastructures[infrastructure_name]
          raise InfrastructureErrors::NoSuchInfrastructureError.new(infrastructure_name) if facade_class.nil?
          facade_class.new
        end

    raise InfrastructureErrors::NoSuchInfrastructureError.new(infrastructure_name) if facade.nil?
    facade
  end

  # returns a list of all supported infrastructure ids (short names)
  def self.get_registered_infrastructure_names
    names = other_infrastructures.keys +
      PlGridFacadeFactory.instance.provider_names +
      CloudFacadeFactory.instance.provider_names # +
      # ClusterFacadeFactory.instance.provider_names
    names.map &:to_s
  end

  def self.get_all_infrastructures
    InfrastructureFacadeFactory.get_registered_infrastructure_names.map do |name|
      InfrastructureFacadeFactory.get_facade_for(name)
    end
  end

  def self.get_all_sm_records(*args)
    infrastructures = get_all_infrastructures +
                      ClusterFacadeFactory.instance.provider_names.collect { |facade_name|
                        InfrastructureFacadeFactory.get_facade_for(facade_name)
                      }

    (infrastructures.collect { |facade| facade.get_sm_records(*args) }).flatten
  end

  ##
  # Queries all available sm records collections and returns array with results matching arguments.
  # Possible cond and opts can be found in MongoActiveRecord#where.
  def self.get_sm_records_by_query(cond = {}, opts = {})
    get_all_infrastructures.flat_map {|facade| facade.class.sm_record_class.where(cond, opts).to_a}
  end

  # Get JSON data for build a base tree for Infrastructure Tree _without_ Simulation Manager
  # nodes. Starting with non-cloud infrastructures and cloud infrastructures, leaf nodes
  # are fetched recursivety with tree_node methods of every concrete facade.
  def self.list_infrastructures(user_id)
    [
        *(InfrastructureFacadeFactory.other_infrastructures.values.map do |facade_class|
          facade_class.new.to_h(user_id)
        end),
        {
            name: I18n.t('infrastructures_controller.tree.plgrid'),
            group: 'plgrid',
            children:
                PlGridFacadeFactory.instance.provider_names.map{|name|
                  PlGridFacadeFactory.instance.get_facade(name).to_h(user_id).merge(group: 'plgrid')
                } +
                ClusterFacadeFactory.instance.provider_names(plgrid: true, public: true).map{|cluster_record_id|
                  ClusterFacadeFactory.instance.get_facade_for(cluster_record_id).to_h(user_id).merge(group: 'plgrid')
                }
        },
        {
            name: I18n.t('infrastructures_controller.tree.clouds'),
            group: 'cloud',
            children:
                CloudFacadeFactory.instance.provider_names.map do |name|
                  CloudFacadeFactory.instance.get_facade(name).to_h(user_id).merge(group: 'cloud')
                end
        },
        {
            name: 'Computer clusters',
            group: 'clusters',
            children:
                ClusterFacadeFactory.instance.provider_names.map {|cluster_record_id|
                  ClusterFacadeFactory.instance.get_facade_for(cluster_record_id).to_h(user_id).merge(group: 'clusters')
                }.select {|cluster_record| cluster_record[:enabled]}
        }
    ]
  end

  def self.start_all_monitoring_threads
    monit_threads = get_all_infrastructures.map do |facade|
      Rails.logger.info("Starting monitoring thread of '#{facade.long_name}'")

      Thread.start do
        t = facade.monitoring_thread
        t["name"] = facade.short_name
        t
      end
    end

    # monit_threads << Thread.start do
    #   t = ClusterFacade.new(nil, nil).monitoring_thread
    #   t["name"] = 'clusters'
    #   t
    # end

    monit_threads
  end

  def self.start_monitoring_thread_for(infrastructure_name)
    facade = get_facade_for(infrastructure_name)
    Rails.logger.info("Starting monitoring thread of '#{infrastructure_name}'")
    Thread.start do
      begin
        facade.monitoring_thread
      rescue => e
        Rails.logger.error "Uncaught monitoring exception for infrastructure: #{infrastructure_name}: #{e.class}, #{e}\n#{e.backtrace.join("\n")}"
        raise
      end
    end
  end

  def self.get_group_for(infrastructure_name)
    if PlGridFacadeFactory.instance.provider_names.include? infrastructure_name
      'plgrid'
    elsif CloudFacadeFactory.instance.provider_names.include? infrastructure_name
      'cloud'
    elsif ClusterFacadeFactory.instance.provider_names.include? infrastructure_name
      'clusters'
    else
      nil
    end
  end

  private # ---------------- ----- --- --- -- -- -- - - -


  if Rails.env.development? or Rails.env.test?
    def self.other_infrastructures
      require_relative 'dummy_facade'
      self._other_infrastructures.merge('dummy' => DummyFacade)
    end
  else
    def self.other_infrastructures
      self._other_infrastructures
    end
  end

  def self._other_infrastructures
    {
        'private_machine' => PrivateMachineFacade
    }
  end

end
