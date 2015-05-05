require 'test_helper'
require 'json'
require 'supervised_experiment_helper'

class MarkAsCompleteSupervisedExperimentTest < ActionDispatch::IntegrationTest
  include SupervisedExperimentHelper
  
  test "successful mark as complete of supervised experiment" do
    supervised_experiment = ExperimentFactory.create_supervised_experiment(@user.id, @simulation)
    supervised_experiment.save
    experiment_id = supervised_experiment.id
    # test
    supervised_experiment = SupervisedExperiment.find_by_id(experiment_id)
    assert_not supervised_experiment.completed?, 'New experiment must not be completed'
    assert_no_difference 'Experiment.count' do
      post mark_as_complete_experiment_path(experiment_id), results: EXPERIMENT_RESULT.to_json
    end
    response_hash = JSON.parse(response.body)
    # test if response contains only allowed entries with proper values
    assert_nothing_raised do
      response_hash.assert_valid_keys('status')
    end
    assert_equal response_hash['status'], 'ok'

    supervised_experiment = SupervisedExperiment.find_by_id(experiment_id)
    assert supervised_experiment.completed?, 'Marked as complete experiment must be completed'
    assert supervised_experiment.end?, 'Marked as complete experiment must be ended'
    assert_equal EXPERIMENT_RESULT, supervised_experiment.results
  end

  test "mark as complete should raise exception when experiment is not supervised" do
    # create experiment
    experiment = ExperimentFactory.create_experiment(@user.id, @simulation)
    experiment.save
    experiment_id = experiment.id
    # test
    assert_no_difference 'Experiment.count' do
      post mark_as_complete_experiment_path(experiment_id), results: EXPERIMENT_RESULT.to_json
    end
    assert_not flash['error'].nil?, 'Flash[\'error\'] is empty'
    assert_redirected_to experiments_path
  end

  test "mark as complete when status is error should set is_error flag on experiment with optional reason" do
    supervised_experiment = ExperimentFactory.create_supervised_experiment(@user.id, @simulation)
    supervised_experiment.save
    experiment_id = supervised_experiment.id
    
    supervised_experiment = SupervisedExperiment.find_by_id(experiment_id)
    assert_not supervised_experiment.is_error 'New experiment should not be in error'
    assert_no_difference 'Experiment.count' do
      post mark_as_complete_experiment_path(experiment_id), status: 'error', reason: REASON
    end
    response_hash = JSON.parse(response.body)
    # test if response contains only allowed entries with proper values
    assert_nothing_raised do
      response_hash.assert_valid_keys('status')
    end
    assert_equal response_hash['status'], 'ok'

    supervised_experiment = SupervisedExperiment.find_by_id(experiment_id)
    assert supervised_experiment.is_error 'Experiment should be in error after proper query'
    assert_equal supervised_experiment.error_reason, REASON

  end

  test "successful start of supervised experiment without starting supervisor script" do
    # mocks
    # mock supervised experiment instance to return specified id (needed to test post params to supervisor)
    supervised_experiment = ExperimentFactory.create_supervised_experiment(@user.id, @simulation)
    supervised_experiment.expects(:id).returns(BSON::ObjectId(EXPERIMENT_ID))
    ExperimentFactory.expects(:create_supervised_experiment).returns(supervised_experiment)
    # mock experiment supervisor response with testing proper query params
    RestClient.expects(:post).never
    # test
    assert_difference 'Experiment.count', 1 do
      post "#{start_supervised_experiment_experiments_path}.json", simulation_id: @simulation.id
    end
    response_hash = JSON.parse(response.body)
    # test if response contains only allowed entries with proper values
    assert_nothing_raised do
      response_hash.assert_valid_keys('status', 'experiment_id')
    end
    assert_equal response_hash['status'], 'ok'
    assert_equal response_hash['experiment_id'], EXPERIMENT_ID.to_s
  end
end
