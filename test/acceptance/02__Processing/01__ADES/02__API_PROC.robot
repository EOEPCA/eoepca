*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Resource  ADES.resource
Library  OperatingSystem
Library  String
Library  Process

Suite Setup  API_PROC Suite Setup  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}


*** Variables ***
${API_PROC_PATH_PREFIX}=  /wps3
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/uma2-configuration
*** Test Cases ***
API_PROC service is alive
  API_PROC Request Processes Valid  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}

API_PROC available processes
  API_PROC Processes Are Expected  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${INITIAL_PROCESS_NAMES}  ${RPT_TOKEN}

API_PROC deploy process
  API_PROC Deploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json  ${RPT_TOKEN}
  Sleep  5  Waiting for process deploy process to complete asynchronously
  API_PROC Is Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${RPT_TOKEN}

API_PROC execute process
  ${location}=  API_PROC Execute Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${RPT_TOKEN}
  Sleep  3  Waiting for process execution to start
  ${job_id}=  API_PROC Get Job ID From Location  ${location}
  API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}  ${RPT_TOKEN}

API_PROC undeploy Process
  API_PROC Undeploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_undeploy.json  ${RPT_TOKEN}
  Sleep  3  Waiting for process undeploy process to complete asynchronously
  API_PROC Is Not Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${RPT_TOKEN}
  PDP Delete policies


*** Keywords ***
API_PROC Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

API_PROC Request Processes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  authorization=Bearer ${token}
  Log  ${headers}
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  Log  ${resp}
  [Return]  ${resp}

API_PROC Request Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Deploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

ADES User A Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}  ${resp}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptA}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${rptA}
  ${file_data}=  Get Binary File  ${filename}
  ${val}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${val}
  [Return]  ${val}

API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token} 
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  ${val}=  builtIn.Run Keyword If  "${resp}"=="<Response [401]>"  ADES User A Undeploy Process  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}  ${resp}
  Status Should Be  201  ${val}

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

UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  [Return]  ${ticket}

UMA Get Token Endpoint
  [Arguments]  ${well_known} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

PDP Delete policies
  Create Session  pdp  ${UM_BASE_URL}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_PROC1}  headers=${headers}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_PROC2}  headers=${headers}

UMA Call Shell Access Token
  [Arguments]  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${token_endpoint}
  ${a}=  Run Process  bash  ${CURDIR}${/}..${/}..${/}01__UserManagement${/}01__LoginService${/}rpt.sh  -S  -a  ${token_endpoint}  -t  ${ticket}  -i  ${client_id}  -p  ${client_secret}  -s  openid  -c  ${token}
  [Return]  ${a.stdout}

UMA Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token}

UMA Get Access Token Valid
  [Arguments]  ${well_known}  ${ticket}  ${token}  ${client_id}  ${client_secret}  
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell Access Token  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  ${match}  ${value}  Run Keyword And Ignore Error  Should Contain  ${resp}  access_token
  ${RETURNVALUE}  Set Variable If  '${match}' == 'PASS'  ${True}  ${False}
  ${access_token}=  builtIn.Run Keyword If  "${RETURNVALUE}"=="True"  UMA Get Access Token From Response  ${resp}
  [Return]  ${access_token}

ADES User A execute Proc1
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}  ${resp}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptA}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${rptA}
  ${file_data}=  Get Binary File  ${filename}
  ${val}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${val}
  #Set Global Variable  ${LOCATION}  ${val.headers["Location"].split("${base_url}")[-1]}
  #OperatingSystem.Create File  ${CURDIR}${/}location.txt  ${LOCATION}
  [Return]  ${val}

API_PROC Execute Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  ${val}=  builtIn.Run Keyword If  "${resp}"=="<Response [401]>"  ADES User A execute Proc1  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}  ${resp}
  Status Should Be  201  ${val}
  [Return]  ${val.headers["Location"].split("${base_url}")[-1]}

API_PROC Get Job ID From Location
  [Arguments]  ${location}
  ${job_id}=  Evaluate  $location.split("/")[-1]
  [Return]  ${job_id}

API_PROC Check Job Status Success
  [Arguments]  ${base_url}  ${location}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  FOR  ${index}  IN RANGE  40
    Sleep  30  Loop wait for processing execution completion
    ${resp}=  Get Request  ades  ${location}  headers=${headers}
    Status Should Be  200  ${resp}
    ${status}=  Set Variable  ${resp.json()["status"]}
    Exit For Loop If  "${status}" != "running"
  END
  Should Match  ${resp.json()["status"]}  successful
  Should Match  ${resp.json()["message"]}  Done
  Should Match  ${resp.json()["progress"]}  100