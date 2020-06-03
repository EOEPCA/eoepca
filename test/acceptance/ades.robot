*** Settings ***
Library  RequestsLibrary
Library  XML
Library  Collections
Library  OperatingSystem

Suite Setup  ADES Suite Setup  ${BASE_URL}  ${WPS_PATH_PREFIX}  ${API_PATH_PREFIX}


*** Variables ***
${BASE_URL}=  http://localhost:7777
${WPS_PATH_PREFIX}=  /zoo
${API_PATH_PREFIX}=  /wps3


*** Test Cases ***  (WPS)
WPS service is alive
  WPS Get Capabilities Valid  ${BASE_URL}  ${WPS_PATH_PREFIX}

WPS available processes
  WPS Processes Are Expected  ${BASE_URL}  ${WPS_PATH_PREFIX}  ${INITIAL_WPS_PROCESS_NAMES}


*** Test Cases ***  (OGC API Processes)
API_PROC service is alive
  API_PROC Request Processes Valid  ${BASE_URL}  ${API_PATH_PREFIX}

API_PROC available processes
  API_PROC Processes Are Expected  ${BASE_URL}  ${API_PATH_PREFIX}  ${INITIAL_API_PROCESS_NAMES}

API_PROC deploy process
  API_PROC Deploy Process  ${BASE_URL}  ${API_PATH_PREFIX}  eo_metadata_generation_1_0  eo_metadata_generation_1_0.json
  Sleep  2  Waiting for process deploy process to complete asynchronously
  API_PROC Is Deployed  ${BASE_URL}  ${API_PATH_PREFIX}  eo_metadata_generation_1_0

API_PROC undeploy Process
  API_PROC Undeploy Process  ${BASE_URL}  ${API_PATH_PREFIX}  eo_metadata_generation_1_0  eo_metadata_generation_1_0_undeploy.json
  Sleep  2  Waiting for process undeploy process to complete asynchronously
  API_PROC Is Not Deployed  ${BASE_URL}  ${API_PATH_PREFIX}  eo_metadata_generation_1_0

*** Keywords ***  (ADES)
ADES Suite Setup
  [Arguments]  ${base_url}  ${wps_path_prefix}  ${api_path_prefix}
  Log  This is ADES Suite Setup
  WPS Suite Setup  ${base_url}  ${wps_path_prefix}
  API_PROC Suite Setup  ${base_url}  ${api_path_prefix}


*** Keywords ***  (WPS)
WPS Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}
  Set Suite Variable  @{INITIAL_WPS_PROCESS_NAMES}  @{processes}

WPS Get Capabilities
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}

WPS Get Capabilities Valid
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Get Capabilities  ${base_url}  ${path_prefix}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

WPS Get Process List
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Get Capabilities Valid  ${base_url}  ${path_prefix}
  ${processes}=  WPS Get Process Names From Response  ${resp}
  [Return]  @{processes}

WPS Get Process Names From Response
  [Arguments]  ${resp}
  ${root}=  Parse XML  ${resp.text}
  ${processes}=  Get Elements  ${root}  ProcessOfferings/Process
  ${process_names}=  Create List
  FOR  ${process}  IN  @{processes}
    ${name}=  Get Element  ${process}  Identifier
    Log  ${name.text}
    Append To List  ${process_names}  ${name.text}
  END
  [Return]  ${process_names}

WPS Processes Are Expected
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True


*** Keywords ***  (OGC API Processes)
API_PROC Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}
  Set Suite Variable  @{INITIAL_API_PROCESS_NAMES}  @{processes}

API_PROC Request Processes
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  [Return]  ${resp}

API_PROC Request Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  API_PROC Request Processes  ${base_url}  ${path_prefix}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Deploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Is Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}
  Should Contain  ${processes}  ${process_name}

API_PROC Is Not Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}
  Should Not Contain  ${processes}  ${process_name}

API_PROC Get Process List
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  API_PROC Request Processes Valid  ${base_url}  ${path_prefix}
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
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True
