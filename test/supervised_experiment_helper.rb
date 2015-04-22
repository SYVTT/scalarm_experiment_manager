require 'db_helper'

module SupervisedExperimentHelper
  include DBHelper

  USER_NAME = BSON::ObjectId.new.to_s
  EXPERIMENT_ID = BSON::ObjectId.new.to_s
  SCRIPT_ID = 'script_id'
  PASSWORD = 'password'
  PID = 'pid'
  EXPERIMENT_SUPERVISOR_ADDRESS = 'http://localhost:13337/start_supervisor_script'
  RESPONSE_ON_SUCCESS = {
      'status' => 'ok',
      'pid' => PID
  }
  REASON = 'reason'
  RESPONSE_ON_FAILURE = {
      'status' => 'error',
      'reason' => REASON
  }
  INPUT_SCRIPT_PARAMS = {
      'maxiter' => 1,
      'dwell' => 1,
      'schedule' => 'boltzmann'
  }
  FULL_SCRIPT_PARAMS = {
      'maxiter' => 1,
      'dwell' => 1,
      'schedule' => 'boltzmann',
      'experiment_id' => EXPERIMENT_ID,
      'user' => USER_NAME,
      'password' => PASSWORD,
      'parameters' => [
          {
              'type' => 'float',
              'id' => 'c___g___x',
              'min' => -3,
              'max' => 3,
              'start_value' => 0
          },
          {
              'type' => 'int',
              'id' => 'c___g___y',
              'min' => -2,
              'max' => 2,
              'start_value' => 0
          },
          {
              'type' => 'string',
              'id' => 'c___g___z',
              'allowed_values' => %w(aaa bbb ccc),
              'start_value' => 'aaa'
          }
      ],
  }
  INPUT_SPECIFICATION = [
      {
          'id' => 'c',
          'label' => 'Opis funkcji',
          'entities' =>
              [
                  {
                      'id' => 'g',
                      'label' => 'Argumenty funkcji',
                      'parameters' =>
                          [
                              {
                                  'id' => 'x',
                                  'label' => 'x',
                                  'type' => 'float',
                                  'min' => -3,
                                  'max' => 3,
                                  'index' => 1,
                                  'value' => '-3'
                              },
                              {
                                  'id' => 'y',
                                  'label' => 'y',
                                  'type' => 'int',
                                  'min' => -2,
                                  'max' => 2,
                                  'index' => 2,
                                  'value' => '-2'
                              },
                              {
                                  'id' => 'z',
                                  'label' => 'z',
                                  'type' => 'string',
                                  'index' => 3,
                                  'allowed_values' => %w(aaa bbb ccc)
                              }
                          ]
                  }
              ]
      }
  ]
  EXPERIMENT_RESULT = {
      'result' => 'result'
  }

  @@simulation = Simulation.new(name: 'name', description: 'description',
                                input_parameters: {}, input_specification: INPUT_SPECIFICATION)
  @@user = ScalarmUser.new({login: USER_NAME})

  def setup
    super
    # log in user and set sample simulation
    @@user.password = PASSWORD
    @@user.save
    post login_path, username: USER_NAME, password: PASSWORD
    @@simulation.user_id = @@user.id
    @@simulation.save
    # mock information service
    information_service = mock do
      stubs(:get_list_of).returns([])
      stubs(:sample_public_url).returns(nil)
    end
    InformationService.stubs(:new).returns(information_service)
  end

end