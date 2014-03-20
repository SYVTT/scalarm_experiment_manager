var I18n = I18n || {};
I18n.translations = {"en":{"date":{"formats":{"default":"%Y-%m-%d","short":"%b %d","long":"%B %d, %Y"},"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"order":["year","month","day"]},"time":{"formats":{"default":"%a, %d %b %Y %H:%M:%S %z","short":"%d %b %H:%M","long":"%B %d, %Y %H:%M"},"am":"am","pm":"pm"},"support":{"array":{"words_connector":", ","two_words_connector":" and ","last_word_connector":", and "}},"number":{"format":{"separator":".","delimiter":",","precision":3,"significant":false,"strip_insignificant_zeros":false},"currency":{"format":{"format":"%u%n","unit":"$","separator":".","delimiter":",","precision":2,"significant":false,"strip_insignificant_zeros":false}},"percentage":{"format":{"delimiter":"","format":"%n%"}},"precision":{"format":{"delimiter":""}},"human":{"format":{"delimiter":"","precision":3,"significant":true,"strip_insignificant_zeros":true},"storage_units":{"format":"%n %u","units":{"byte":{"one":"Byte","other":"Bytes"},"kb":"KB","mb":"MB","gb":"GB","tb":"TB"}},"decimal_units":{"format":"%n %u","units":{"unit":"","thousand":"Thousand","million":"Million","billion":"Billion","trillion":"Trillion","quadrillion":"Quadrillion"}}}},"datetime":{"distance_in_words":{"half_a_minute":"half a minute","less_than_x_seconds":{"one":"less than 1 second","other":"less than %{count} seconds"},"x_seconds":{"one":"1 second","other":"%{count} seconds"},"less_than_x_minutes":{"one":"less than a minute","other":"less than %{count} minutes"},"x_minutes":{"one":"1 minute","other":"%{count} minutes"},"about_x_hours":{"one":"about 1 hour","other":"about %{count} hours"},"x_days":{"one":"1 day","other":"%{count} days"},"about_x_months":{"one":"about 1 month","other":"about %{count} months"},"x_months":{"one":"1 month","other":"%{count} months"},"about_x_years":{"one":"about 1 year","other":"about %{count} years"},"over_x_years":{"one":"over 1 year","other":"over %{count} years"},"almost_x_years":{"one":"almost 1 year","other":"almost %{count} years"}},"prompts":{"year":"Year","month":"Month","day":"Day","hour":"Hour","minute":"Minute","second":"Seconds"}},"helpers":{"select":{"prompt":"Please select"},"submit":{"create":"Create %{model}","update":"Update %{model}","submit":"Save %{model}"}},"title":"Scalarm Experiment Manager","copyright":"Copyright © 2010-2014 Academic Computer Centre Cyfronet AGH \u003Cbr/\u003EAll rights reserved.","login-title":"Scalarm - platform for data farming experiments","account-title":"Account management panel","navbar":{"experiments_link":"Experiment view","simulations_link":"Simulation view","account_link":"Logged as '%{login}'","logout_link":"Logout"},"registered_simulation_scenario_list":{"label":"Registered simulations","destroy_button":"Destroy","empty_list":"There is no simulation registered. Go to registration form and register new simulations."},"simulation_scenario_list":{"label":"Select simulation scenario to conduct a new experiment","empty_list":"There is no experiment defined to run. Go to registration form and define new experiments.","go_to_input_definition_button":"Go to input definition"},"running_experiments":{"label":"Running experiments (click on the experiment to go to the monitoring panel)"},"historical_experiments":{"label":"Historical experiments"},"login_success":"You have log in successfully","logout_success":"You have log out successfully","password_changed":"You have changed your password.","password_repeat_error":"'Password' and 'Repeat password' must be equal!","openid":{"provider_discovery_failed":"OpenID discovery failed for %{provider_url}: %{error}","verification_success":"Verification of %{identity} succeeded.","cancelled":"OpenID transaction cancelled.","unknown_status":"OpenID unknown status: %{status}","verification_failed_identity":"Verification of %{identity} failed: %{message}","verification_failed":"Verification failed: %{message}","login":"Login with %{provider} OpenID","wrong_endpoint":"Got response from wrong OpenID endpoint: %{endpoint}","google":{"no_openid_user":"There is no Scalarm user registered with Google OpenID E-Mail: %{email}","no_email_provided":"Error authenticating with OpenID: no email attribute provided by server."}},"registered_executors_list":{"label":"Registered simulation executors","empty_list":"There is no simulation executor defined to run. Go to registration form and define new ones."},"registered_input_writers_list":{"label":"Registered simulation input writers","empty_list":"There is no simulation input writer defined to run. Go to registration form and define new ones."},"registered_output_readers_list":{"label":"Registered simulation output readers","empty_list":"There is no simulation output reader defined to run. Go to registration form and define new ones."},"no_running_experiment_response":"No experiment running","registered_progress_monitors_list":{"label":"Registered simulation progress monitors","empty_list":"There is no simulation progress monitor defined to run. Go to registration form and define new ones."},"experiments":{"show":{"stats_header":"Simulation statistics","progress_bar_header":"Experiment progress bar"},"monitoring_actions":{"actions_header":"Actions","stop_button":"Stop experiment","extend_button":"Extend","boost_button":"Boost","scheduling_button":"Set scheduling","destroy_button":"Destroy experiment","download_results_button":"Download results","binaries_results_button":"Simulations output (binaries)","get_configurations_button":"Configurations (CSV)","progress_information_button":"Show progress","booster":{"header":"Increase computational power"},"stop_dialog":{"header":"Are you sure you want to stop the experiment?"},"destroy_dialog":{"header":"Are you sure you want to destroy the experiment?"},"true":"Yes","false":"No"},"monitoring_table":{"show_completed":"Show/Hide completed","show_running":"Show/Hide running","header":"Progress information"},"import":{"csv_parameters_not_valid":"The provided CSV file is not compatible with the selected simulation"},"click_to_expand":"(click to expand)","information_panel":{"experiment_info_title":"Experiment information","experiment_name":"Name","experiment_description":"Description"},"experiment_links":{"navigation_link":"Experiments","running_experiments":"Running experiments","simulation_scenarios":"Simulation scenarios","historical_experiments":"Historical experiments","data_exploration_link":"Data exploration methods","histograms":"Histograms","regression_trees":"Regression trees","scatter_plots":"Scatter plots"},"extension_dialog":{"header":"Experiment extension dialog","expand_header":"Expand the input parameter space","parametrization":"Parametrization:","doe":"Included in DoE:","values":"Values","parameter":"Parameter:","minimum":"Minimum","maximum":"Maximum","step":"Step"},"booster_dialog":{"plgrid":"PL-Grid","cloud":"Clouds","private_machine":"Private resources"},"extend_input_values":{"extension_response":"%{count} simulations were created"}},"simulations":{"deregister_button":"Deregister","go_to_registriation":"Register new simulation or adapter","empty_component":"\u003CN/A\u003E","registration":{"title":"Simulation registration","experiments_label":"Simulation scenario registration","simulation_name":"Simulation name","simulation_description":"Simulation description","simulation_input":"Input definition","simulation_binaries":"Simulation binaries","input_writer":"Input writer","output_reader":"Output reader","executor":"Executor","progress_monitor":"Progress monitor","upload":"Upload","component_registration_title":"Adapter registration","component_name":"Adapter name","component_code":"Adapter code","component_type":"Adapter type","component_header":"%{component} registration","select_file":"or insert file:"},"conduct_experiment":{"title":"Scalarm - prepare new experiment","empty_simulation":"Simulation for this experiment is unavailable","simulation_overview_header":"Simulation information","simulation_overview_name":"Simulation name","simulation_overview_description":"Simulation description","input_header":"Parameter space specification","input_parametrization_types":"Parametrization","input_parameter_values":"Parameter values","input_doe":"Design of Experiment","import":"Import parameter space","submit_button":"Start experiment","experiment_size_button":"Calculate experiment size","experiment_size_dialog_body":"Calculated experiment size - \u003Cspan id=\"calculated-experiment-size\"\u003E\u003C/span\u003E simulations","time_constraint_label":"Time constraint for simulation execution ([s])","repeatation_label":"Execution repeatation of each input parameters combination","parametrization_tab":{"header":"Specify parametrization for each input parameter below","entity_group_header":"Group - '%{label}'","entity_header":"'%{label}'","parameter_header":"Set parameter '%{label}' to:"},"parameters_values_tab":{"header":"Specify values for each input parameter you want to explore"}},"import_tab":{"header":"Import parameter space from a CSV file","submit_import":"Import","import_label":"Select a CSV file with the parameter space:"},"show":{"title":"Simulation %{id}","status_section":"Status:","status":{"completed":"completed","to_send":"not sent","running":"running"},"started_at":"Started at:","completed_at":"Completed at:","input_section":"Input:","output_section":"Output:","binary_output_header":"Binary output:","stdout_header":"Simulation STDOUT:"},"import":{"parameter_selection_table":{"parameter_id":"Parameter full id","section_header":"Select parameters which should be included in the parameter space","parameters_per_row":"Values in each row"}},"adapter_destroyed":"The selected adapter has been removed"},"plgrid":{"login":{"ok":"Your credentials have been updated","error":"An error occured"},"job_submission":{"authentication_failed":"An exception occured during authentication - %{ex}. Please check if the host is available and the username and password are correct.","error":"An exception occured - %{ex}. Please check if the host is available and the username and password are correct.","ok":"You have scheduled %{instances_count} jobs","no_credentials":"You have to provide Grid credentials first!"},"job_desc":"\u003Cb\u003EJob id\u003C/b\u003E: %{job_id}\u003Cbr/\u003E\u003Cb\u003EScheduled at\u003C/b\u003E: %{created_at}\u003Cbr/\u003E\u003Cb\u003EExperiment id\u003C/b\u003E: %{experiment_id}"},"pl_cloud":{"login":{"ok":"Your credentials have been updated","error":"An error occured"}},"amazon":{"login":{"ok":"Your credentials have been updated","error":"An error occured","wrong_image_id":"Illegal image id"},"start_sm":{"errors":{"no_secrets":"You have to provide Amazon secrets first!","no_ami":"You have to provide Amazon AMI information first!","could_not_create_vms":"Exception occured during creating virtual machines"}}},"private_machine":{"login":{"ok":"Your credentials have been added","error":"An error occured on adding credentials"}},"charts":{"hide_button":"Hide chart","load_button":"Load chart","histogram":{"section_header":"Basic statistics about Measures of Effectiveness","header":"Basic statistics about '%{moe}'","select_moe":"Select MoE","resolution":"Number of bars"},"regression":{"section_header":"Regression trees","header":"Regression tree for the '%{moe}' Measure of Effectiveness","select_moe":"Select MoE"},"scatter":{"section_header":"Bivariate analysis","header":"Scatter plot: '%{x_axis}' versus '%{y_axis}'","select_x":"Select values for the X axis (MoE or input)","select_y":"Select values for the Y axis (MoE or input)"}},"security":{"sim_authorization_error":"Simulation Manager '%{sm_uuid}' is not authorized to execute experiment '%{experiment_id}'"},"experiment_not_found":"Experiment '%{experiment_id}' for user '%{user}' not found","new_adapter_added":"New adapter has been added.","infrastructure":{"credentials":{"images_manager":{"info":"You can add image credentials for Clouds with valid secrets provided, which can be set in %{account_link} page.","login":"Login","password":"Password","cloud_name":"Cloud name","image_id":"Image ID","actions":"Actions","remove":"Remove record","image_submission_label":"Add image credentials","image_table_label":"Manage submitted image credentials"},"private_machines_manager":{"host":"Host","port":"Port","login":"Login","password":"Password","actions":"Actions","remove":"Remove record","machine_submission_label":"Add resource credentials","machine_table_label":"Manage submitted resources credentials","table_label":"Manage submitted private resources credentials"},"credentials_label":"Credentials","plgrid":{"credentials_label":"Please, provide your credentials to the PL-Grid infrastructure","credentials":{"secrets":"PL-Grid secrets","host":"User Interface (UI) host","login":"UI login","password":"UI password"}},"amazon":{"credentials_label":"Please, provide your credentials to Amazon EC2","credentials":{"secrets":"Amazon EC2 secrets","key_id":"Access Key Id","secret_key":"Secret Access Key"}},"pl_cloud":{"credentials_label":"Please, provide your credentials to access the PL-Grid infrastructure","credentials":{"secrets":"PLGrid Cloud secrets","login":"UI login","password":"UI password"}},"private_machine":{"credentials_label":"Please, provide your credentials to access private resources"}},"information":{"instance_counter":"Instance counter","image_label":"Image","vm_type":"Instance type","grant_id":"Grant","time_constraint":"Job time constraint [min]","start_at":"Start at (\"hh:mm:ss\" format)","submit":"Submit","remove_credentials":"Remove credentials","credentials_info":"Please, provide valid credentials to your Cloud of choice in the %{account_link} panel, before scheduling virtual machines.","no_credentials_info":"No valid credentials provided for %{cloud_name}","submission_label":"Simulation Manager submission","scheduled_label":"Scheduled Simulation Managers","plgrid":{"scheduler":"Scheduler","scheduled_label":"Scheduled jobs"},"amazon":{"security_group":"Security group"},"private_machine":{"machine_id":"Private resource"}}},"user_controller":{"account":{"manage_scalarm":"Manage your Scalarm account","manage_infrastructures":"Manage your infrastructures credentials","login":"Login:","certificate":"Certificate DN:","password":"Password:","repeat_password":"Repeat password:","change_password":"Change password","empty_dn":"\u003CN/A\u003E","plgrid":"PL-Grid credentials","pl_cloud":"PLGrid Cloud credentials","amazon":"Amazon Elastic Compute Cloud credentials","images_manager":"Cloud virtual machine images management","private_machines_manager":"Private resources credentials"}},"infrastructures_controller":{"image_removed":"Removed %{cloud_name} image credentials with id %{image_id}","image_not_found":"Image record not found","credentials_removed":"Removed credentials for %{name}","credentials_not_removed":"There was no credentials for %{name} to remove","priv_machine_creds_removed":"Removed %{name} private resource credentials","priv_machine_creds_not_removed":"There was no credentials in database to remove","permission_denied":"Permission denied"},"infrastructure_facades":{"plgrid":{"current_state":"Currently %{jobs_count} jobs are scheduled or running."},"cloud":{"provide_secrets":"You have to provide %{cloud_name} secrets first!","client_problem":"Problem connecting with %{cloud_name} - please check provided cloud credentials.","provide_image_secrets":"You have to provide image information first!","image_not_exists":"Image %{image_id} does not exists on %{cloud_name}. Please verify it.","image_permission":"This image belongs to other user","image_cloud_error":"This image is for other Cloud","scheduled_info":"You have scheduled %{count} virtual machines on %{cloud_name}!","scheduled_error":"Virtual machines scheduling failed, error: %{error}","current_state_no_creds":"No information available due to lack of credentials for %{cloud_name}","current_state_count":"You have %{count} Scalarm virtual machines scheduled","current_state_exception":"No information available due to exception: %{exception}"},"private_machine":{"unknown_machine_id":"There is no requested private resource in database","no_permissions":"Scalarm user #{scalarm_login} has no registered credentials for machine #{name}","scheduled_info":"You have scheduled %{count} tasks on %{machine_name}!","current_state":"Currently %{tasks} tasks are scheduled or running on private resources."}}}};