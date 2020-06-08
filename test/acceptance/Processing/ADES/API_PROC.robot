*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Resource  ADES.resource
Library  OperatingSystem

Suite Setup  API_PROC Suite Setup  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}


*** Variables ***
${API_PROC_PATH_PREFIX}=  /wps3


*** Test Cases ***
API_PROC service is alive
  API_PROC Request Token Processes Valid  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}

API_PROC resource is retrieved
  API_PROC Request Token Processes Valid ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}

PI_PROC resource is not retrieved
  API_PROC Request Token Processes Invalid ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}

API_PROC available processes
  API_PROC Processes Are Expected  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${INITIAL_PROCESS_NAMES}

API_PROC deploy process
  API_PROC Deploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json
  Sleep  3  Waiting for process deploy process to complete asynchronously
  API_PROC Is Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0

API_PROC execute process
  ${location}=  API_PROC Execute Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json
  Sleep  3  Waiting for process execution to start
  ${job_id}=  API_PROC Get Job ID From Location  ${location}
  API_PROC Check Job Exists  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${job_id}
  API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}

API_PROC undeploy Process
  API_PROC Undeploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_undeploy.json
  Sleep  3  Waiting for process undeploy process to complete asynchronously
  API_PROC Is Not Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0


*** Keywords ***
API_PROC Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

API_PROC Request Processes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Authorization=Bearer ${token}
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  [Return]  ${resp}

API_PROC Request Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Request Token Processes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  Authorization=Bearer ${token}
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  [Return]  ${resp}

API_PROC Request Token Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Token Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Request Token Processes Invalid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Token Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  401  ${resp}
  [Return]  ${resp}

API_PROC Deploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  Authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  Authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Is Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Should Contain  ${processes}  ${process_name}

API_PROC Is Not Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Should Not Contain  ${processes}  ${process_name}

API_PROC Get Process List
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes Valid  ${base_url}  ${path_prefix}  ${token}
  @{processes}=  API_PROC Get Process Names From Response  ${resp}
  [Return]  @{processes}

API_PROC Get Process Names From Response
  [Arguments]  ${resp}
  ${json}=  Set Variable  ${resp.json()}
  ${process_names}=  Create List
  FOR  ${process}  IN  @{json["processes"]}
    Append To List  ${process_names}  ${process["id"]}
  END
  [Return]  ${process_names}

API_PROC Processes Are Expected
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True

API_PROC Execute Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  Authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}
  [Return]  ${resp.headers["Location"]}

API_PROC Get Job ID From Location
  [Arguments]  ${location}
  ${job_id}=  Evaluate  $location.split("/")[-1]
  [Return]  ${job_id}

API_PROC Check Job Exists
  [Arguments]  ${base_url}  ${path_prefix}  ${job_id}
  Log  zzz job_id is ${job_id}  console=True

API_PROC Check Job Status Success
  [Arguments]  ${base_url}  ${location}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  Authorization=Bearer ${token}
  ${resp}=  Get Request  ades  ${location}  headers=${headers}
  Status Should Be  200  ${resp}
  Should Match  ${resp.json()["status"]}  "successful"
