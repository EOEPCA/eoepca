*** Settings ***
Documentation  Tests for the ADES WPS endpoint
Resource  ADES.resource
Library  XML
Library  Process
Library  OperatingSystem
Library  String
Library  ../../01__UserManagement/ScimClient.py  ${UM_BASE_URL}/

Suite Setup  API_PROC Suite Setup  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}
*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${API_PROC_PATH_PREFIX}=  /wps3
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/uma2-configuration

*** Test Cases ***
ADES Protection as Service
  PEP Delete Resource  ${UM_BASE_URL}
  #User C attempts to perform a GetCapabilities. Access granted. NO TICKET
  WPS Get Capabilities Without Token  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}
  #UserD gets id_token
  UMA Get ID Token Valid  ${WELL_KNOWN_PATH}  ${C_ID_UMA}  ${C_SECRET_UMA}
  #User D protects the root path of ADES (“/”) with an “Authenticated” scope
  PEP Register ADES
  #UserC attempts to perform a GetCapabilities. Unauthorized 401 return Ticket
  ${resp}=  WPS Get Capabilities Without Token  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  #Check ticket against UMA and get Unauthorized
  ${rpt}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  NA  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  WPS Get Capabilities  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}  ${rpt}
  Status Should Be  401  ${validation}
  #UserA and UserB attempts to perform a GetCapabilities
  ${resp}=  WPS Get Capabilities Without Token  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptA}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  WPS Get Capabilities  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}  ${rptA}
  Status Should Be  200  ${validation}
  ${resp}=  WPS Get Capabilities Without Token  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptB}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  WPS Get Capabilities  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}  ${rptB}
  Status Should Be  200  ${validation}
  ${rpt}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${ID_TOKEN}  ${C_ID_UMA}  ${C_SECRET_UMA}
  Set Global Variable  ${RPT_TOKEN}  ${rpt}

ADES Application Deployment Protection
#   User A deploys Proc1
  

  ${resp}=  API_PROC Deploy Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json  ${UA_TK}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptA}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  API_PROC Deploy Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json  ${rptA}
  Status Should Be  201  ${validation}
#   User B execute Proc1  
  ${resp}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UB_TK}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptB}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptB}
  Status Should Be  201  ${validation}
#   User A registers the resulting application Proc1 as a protected resource
#   User A assigns an ownership policy to Proc1
  PEP Register Proc1
  PDP Register Proc1  ${UM_BASE_URL}
#   User A registers the undeploy operation for Proc1 as a protected resource
#   User A assigns an ownership policy to Proc1
  PDP Register Proc2  ${UM_BASE_URL}
#   User B attempts to undeploy Proc1. Unauthorized.
  ${resp}=  API_PROC Undeploy Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_undeploy.json  ${UB_TK}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptB}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  API_PROC Undeploy Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UB_TK}
  Status Should Be  401  ${validation}

ADES Application Execution Protection
#   User A attempts to execute Proc1. Success → Generation of a Job1 object.
  ${resp}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UA_TK}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  ${rptA}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${val}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptA}
  Status Should Be  201  ${val}
  OperatingSystem.Create File  ${CURDIR}${/}location.txt  ${val.headers["Location"].split("${UM_BASE_URL}")[-1]}
  PEP Register Job1
#   User A registers the Location of the Job1 status as protected resource with ownership policy
  PDP Register Job1  ${UM_BASE_URL}
  ${resp}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UB_TK}
  ${ticketB}=  UMA Get Ticket From Response  ${resp}
  ${rptB}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticketB}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UB_TK}
  Status Should Be  401  ${validation}
  ${status}=  API_PROC Check Job Status Success  ${UM_BASE_URL}  ${val.headers["Location"].split("${UM_BASE_URL}")[-1]}  ${UB_TK}
  Status Should Be  401  ${status}
  ${status}=  API_PROC Check Job Status Success  ${UM_BASE_URL}  ${val.headers["Location"].split("${UM_BASE_URL}")[-1]}  ${rptA}
  Status Should Be  200  ${status}

  
#   API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}  ${RPT_TOKEN}
#   User B attempts to execute Proc1. Unauthorized.
#   User B attempts to retrieve status of Job1. Unauthorized.
#   User A attempts to retrieve status of Job1. OK.
#Policy Ownership and Policy Updates
#   User B attempts to modify Proc1 access policies. Unauthorized. 
#   User A modifies access policy of Job1 Status to Access List including User B.
#   User B attempts to retrieve the status of Job1. OK.
#   User A modifies access policy of Proc1 to Access List including User B.
#   User B attempts to execute Proc1. OK.


*** Keywords ***
API_PROC Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

API_PROC Get Process List
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes Valid  ${base_url}  ${path_prefix}  ${token}
  @{processes}=  API_PROC Get Process Names From Response  ${resp}
  [Return]  @{processes}

API_PROC Request Processes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  authorization=Bearer ${token}
  Log  ${headers}
  ${resp}=  Get Request  pep  /secure${path_prefix}/processes  headers=${headers}
  Log  ${resp}
  [Return]  ${resp}

API_PROC Request Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Get Process Names From Response
  [Arguments]  ${resp}
  ${json}=  Set Variable  ${resp.json()}
  ${process_names}=  Create List
  FOR  ${process}  IN  @{json["processes"]}
    Append To List  ${process_names}  ${process["id"]}
  END
  [Return]  ${process_names}


API_PROC Check Job Status Success
  [Arguments]  ${base_url}  ${location}  ${token}
  ${loc}=  Fetch From Right  ${location}  nip.io/
  Log to Console  ${loc}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  FOR  ${index}  IN RANGE  40
    Sleep  30  Loop wait for processing execution completion
    ${resp}=  Get Request  pep  /secure/${loc}  headers=${headers}
    Status Should Be  200  ${resp}
    ${status}=  Set Variable  ${resp.json()["status"]}
    Exit For Loop If  "${status}" != "running"
  END
  Should Match  ${resp.json()["status"]}  successful
  Should Match  ${resp.json()["message"]}  Done
  Should Match  ${resp.json()["progress"]}  100

PEP Register Job1
  ${a}=  Run Process  python3  ${CURDIR}${/}insertJob1.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Job1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}Job1.txt
  Set Global Variable  ${RES_ID_JOB1}  ${resource_id}


PDP Register Job1
  [Arguments]  ${host}
  Create Session  pdp  ${host}:443  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc1","description":"Proc1 UnDeploy","config":{"resource_id":${RES_ID_JOB1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}},{"EQUAL":{"user_name":"UserA"}}]}]},"scopes":["Authorized"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}


API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token} 
  Create Session  pep  ${base_url}:443  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}  id_token=${UB_TK}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /secure${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  [return]  ${resp}

PEP Register Proc1
  ${a}=  Run Process  python3  ${CURDIR}${/}insertProc1.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Proc1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}Proc1.txt
  Set Global Variable  ${RES_ID_PROC1}  ${resource_id}
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Proc2.txt
  OperatingSystem.Remove File  ${CURDIR}${/}Proc2.txt
  Set Global Variable  ${RES_ID_PROC2}  ${resource_id}

PDP Register Proc1
  [Arguments]  ${host}
  Create Session  pdp  ${host}:443  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc1","description":"Proc1 UnDeploy","config":{"resource_id":${RES_ID_PROC1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}},{"EQUAL":{"user_name":"UserA"}}]}]},"scopes":["Authorized"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  Mi json es ${json}
  Status Should Be  200  ${response}

PDP Register Proc2
  [Arguments]  ${host}
  Create Session  pdp  ${host}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc2","description":"Proc1 Execute","config":{"resource_id":${RES_ID_PROC1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}},{"EQUAL":{"user_name":"UserA"}}]}]},"scopes":["Authorized"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  Mi json es ${json}
  Status Should Be  200  ${response}

API_PROC execute process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  pep  ${base_url}:443  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}  id_token=${UA_TK}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /secure${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  [Return]  ${resp}
  

API_PROC deploy process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}  id_token=${UB_TK}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /secure${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  [Return]  ${resp}
  # Sleep  5  Waiting for process deploy process to complete asynchronously
  # API_PROC Is Deployed  ${base_url}  ${path_prefix}  ${process_name}  ${token}

PEP Delete Resource
  [Arguments]  ${base_url}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${response}=  Delete Request  pep  /secure/resources/${RES_ID_ADES}  headers=${headers}

UMA Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token}

UMA Call Shell Access Token
  [Arguments]  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${token_endpoint}
  ${a}=  Run Process  bash  ${CURDIR}${/}..${/}..${/}01__UserManagement${/}01__LoginService${/}rpt.sh  -S  -a  ${token_endpoint}  -t  ${ticket}  -i  ${client_id}  -p  ${client_secret}  -s  openid  -c  ${token}
  [Return]  ${a.stdout}

UMA Get Access Token Valid
  [Arguments]  ${well_known}  ${ticket}  ${token}  ${client_id}  ${client_secret}  
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell Access Token  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  ${match}  ${value}  Run Keyword And Ignore Error  Should Contain  ${resp}  access_token
  ${RETURNVALUE}  Set Variable If  '${match}' == 'PASS'  ${True}  ${False}
  ${access_token}=  builtIn.Run Keyword If  "${RETURNVALUE}"=="True"  UMA Get Access Token From Response  ${resp}
  [Return]  ${access_token}
  
PEP Register ADES 
  ${a}=  Run Process  python3  ${CURDIR}${/}insertADES.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}ADES.txt
  OperatingSystem.Remove File  ${CURDIR}${/}ADES.txt
  Set Global Variable  ${RES_ID_A}  ${resource_id}

UMA Call Shell ID Token
  [Arguments]  ${endpoint}  ${client_id}  ${client_secret}
  ${a}=  Run Process  sh  ${CURDIR}${/}id.sh  -t  ${endpoint}  -i  ${client_id}  -p  ${client_secret}
  ${n}=  OperatingSystem.Get File  ${CURDIR}${/}1.txt
  [Return]  ${n}

UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  [Return]  ${ticket}

UMA Get ID Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${id_token}=  Get From Dictionary  ${json}  id_token
  [Return]  ${id_token} 

UMA Get ID Token Valid
  [Arguments]  ${well_known}  ${client_id}  ${client_secret}
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell ID Token  ${endpoint}  ${client_id}  ${client_secret}
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  Set Global Variable  ${ID_TOKEN}  ${id_token}
  ${U1}=  OperatingSystem.Get File  ${CURDIR}${/}2.txt
  ${U1}=  UMA Get ID Token From Response  ${U1}
  Set Global Variable  ${UA_TK}  ${U1}
  ${U2}=  OperatingSystem.Get File  ${CURDIR}${/}3.txt
  ${U2}=  UMA Get ID Token From Response  ${U2}
  Set Global Variable  ${UB_TK}  ${U2}
  [Return]  ${id_token}

UMA Get Token Endpoint
  [Arguments]  ${well_known} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

WPS Get Capabilities Without Token
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=False
  ${resp}=  Get Request  ades  /secure${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}

WPS Get Capabilities
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${token}
  ${resp}=  Get Request  ades  /secure${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities  headers=${headers}
  [Return]  ${resp}









