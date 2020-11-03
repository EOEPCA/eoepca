*** Settings ***
Documentation  Tests for the ADES Securization with PEP & PDP
Resource  ADES.resource
Library  XML
Library  Process
Library  OperatingSystem
Library  String
Library  ../../01__UserManagement/ScimClient.py  ${UM_BASE_URL}/
Resource  ../../01__UserManagement/01__LoginService/UMA_Flow2.robot

#Suite Setup  API_PROC Suite Setup  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}
*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${API_PROC_PATH_PREFIX}=  /wps3
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/uma2-configuration

${UMA_USER}=  admin
${UMA_PWD}=  admin_Abcd1234#
${UMA_PATH_PREFIX}=  /wps3
${PATH_TO_RESOURCE}=  ades/mami

${USERA}=  UserA
${USERB}=  UserB
${PASSWORD_USERS}=  defaultPWD

*** Test Cases ***

ADES Protection as Service
  #PEP Delete Resource  ${UM_BASE_URL}
  #User C attempts to perform a GetCapabilities. Access granted. NO TICKET
  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}
  #User D gets id_token
  UMA Get ID Token Valid  ${WELL_KNOWN_PATH}  ${C_ID_UMA}  ${C_SECRET_UMA}
  #User D protects the root path of ADES (“/”) with an “Authenticated” scope
  PEP Register ADES
  #User C attempts to perform a GetCapabilities. Unauthorized 401 return Ticket
  User C KO
  #User A and User B attempt to perform a GetCapabilities
  User A, User B OK  

ADES Application Deployment Protection
#   User A deploys Proc1
  ADES User A deploys Proc1
#   User B execute Proc1 
  ADES User B execute Proc1
#   User A registers the resulting application Proc1 as a protected_access resource
#   User A assigns an ownership policy to Proc1
  PEP Register Proc1
  PDP Register Proc1  ${UM_BASE_URL}
#   User A registers the undeploy operation for Proc1 as a protected_access resource
#   User A assigns an ownership policy to Proc1
  PDP Register Proc2  ${UM_BASE_URL}
#   User B attempts to undeploy Proc1. Unauthorized.
  ADES User B undeploy Proc1
  

ADES Application Execution Protection
#   User A attempts to execute Proc1. Success → Generation of a Job1 object.
  ADES User A execute Proc1
  PEP Register Job1
  #   User A registers the Location of the Job1 status as protected_access resource with ownership policy
  PDP Register Job1  ${UM_BASE_URL}
  #   User B attempts to execute Proc1. Unauthorized.
  ADES User B attempt execute Proc1
  #   User B attempts to retrieve status of Job1. Unauthorized.
  ADES User B retrieve status Job1
  #   User A attempts to retrieve status of Job1. OK.
  ADES User A retrieve status Job1

  
Policy Ownership and Policy Updates
  #   User B attempts to modify Proc1 access policies. Unauthorized. 
  PDP Modify Deny
  #   User A modifies access policy of Job1 Status to Access List including User B.
  #   User A modifies access policy of Proc1 to Access List including User B.
  PDP Modify Policy
  #   User B attempts to retrieve the status of Job1. OK.
  #PDP UserB Status Success  ${UB_RPT}
  #   User B attempts to execute Proc1. OK.
  #PDP UserB Execution Success
  #PDP Delete policies
  Cleanup



*** Keywords ***
ADES User A retrieve status Job1
  ${loc}=  Fetch From Right  ${LOCATION}  nip.io/
  ${rptA}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades/${loc}  ${WELL_KNOWN_PATH}  ${USERA}  ${PASSWORD_USERS}
  Log to Console  ${rptA}
  ${a}=  API_PROC Check Job Status Success  ${UM_BASE_URL}  ${LOCATION}  ${rptA}
  Status Should Be  200  ${a}

ADES User B retrieve status Job1
  ${loc}=  Fetch From Right  ${LOCATION}  nip.io/
  ${rptB}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades/${loc}  ${WELL_KNOWN_PATH}  ${USERB}  ${PASSWORD_USERS}
  ${status}=  API_PROC Check Job Status Success  ${UM_BASE_URL}  ${LOCATION}  ${rptB}
  Status Should Be  401  ${status}

ADES User B attempt execute Proc1
  ${rptB}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${API_PROC_PATH_PREFIX}/processes/eo_metadata_generation_1_0/jobs  ${WELL_KNOWN_PATH}  ${USERB}  ${PASSWORD_USERS}
  Set Global Variable  ${UB_RPT}  ${rptB}
  ${validation}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptB}
  builtIn.Run Keyword If  ${RES_ID_PROC1}!=""  Status Should Be  401  ${validation}
  builtIn.Run Keyword If  ${RES_ID_PROC1}==""  Status Should Be  201  ${validation}

ADES User A execute Proc1
  ${rptA}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${API_PROC_PATH_PREFIX}/processes/eo_metadata_generation_1_0/jobs  ${WELL_KNOWN_PATH}  ${USERA}  ${PASSWORD_USERS}
  Log to Console  ${rptA}
  Log to Console  ${RPT_TOKEN}
  ${val}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptA}
  #Status Should Be  201  ${val}
  Set Global Variable  ${LOCATION}  ${val.headers["Location"].split("${UM_BASE_URL}")[-1]}
  #Set Global Variable  ${LOCATION}  test.${PUBLIC_HOSTNAME}/testPath/555test555
  OperatingSystem.Create File  ${CURDIR}${/}location.txt  ${LOCATION}

ADES User B undeploy Proc1
  ${rptB}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${API_PROC_PATH_PREFIX}/processes/eoepcaadesdeployprocess/jobs  ${WELL_KNOWN_PATH}  ${USERB}  ${PASSWORD_USERS}
  ${validation}=  API_PROC Undeploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptB}
  Status Should Be  401  ${validation}

ADES User B execute Proc1
  ${rptB}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${API_PROC_PATH_PREFIX}/processes/eoepcaadesdeployprocess/jobs  ${WELL_KNOWN_PATH}  ${USERB}  ${PASSWORD_USERS}
  ${validation}=  API_PROC Execute Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptB}
  #Status Should Be  201  ${validation}

ADES User A deploys Proc1
  ${rptA}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${API_PROC_PATH_PREFIX}/processes/eoepcaadesdeployprocess/jobs  ${WELL_KNOWN_PATH}  ${USERA}  ${PASSWORD_USERS}
  Log to Console  ${rptA}
  ${validation}=  API_PROC Deploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json  ${rptA}
  Status Should Be  201  ${validation}

User C KO
  ${resp}=  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}
  ${ticket}=  UMA_Flow2.UMA Get Ticket From Response  ${resp}
  #Check ticket against UMA and get Unauthorized
  ${rpt}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  NA  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  WPS Get Capabilities  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${rpt}
  Status Should Be  401  ${validation}

UMA Get Access Token Valid
  [Arguments]  ${well_known}  ${ticket}  ${token}  ${client_id}  ${client_secret}  
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell Access Token  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  ${match}  ${value}  Run Keyword And Ignore Error  Should Contain  ${resp}  access_token
  ${RETURNVALUE}  Set Variable If  '${match}' == 'PASS'  ${True}  ${False}
  ${access_token}=  builtIn.Run Keyword If  "${RETURNVALUE}"=="True"  UMA Get Access Token From Response  ${resp}
  [Return]  ${access_token}

UMA Call Shell ID Token PEP
  [Arguments]  ${endpoint}  ${client_id}  ${client_secret}
  ${a}=  Run Process  sh  ${CURDIR}${/}id.sh  -t  ${endpoint}  -i  ${client_id}  -p  ${client_secret}
  ${n}=  OperatingSystem.Get File  ${CURDIR}${/}1.txt
  [Return]  ${n}

UMA Get ID Token Valid
  [Arguments]  ${well_known}  ${client_id}  ${client_secret}
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell ID Token PEP  ${endpoint}  ${client_id}  ${client_secret}
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  Set Global Variable  ${ID_TOKEN}  ${id_token}
  ${U1}=  OperatingSystem.Get File  ${CURDIR}${/}2.txt
  ${U1}=  UMA Get ID Token From Response  ${U1}
  Set Global Variable  ${UA_TK}  ${U1}
  ${U2}=  OperatingSystem.Get File  ${CURDIR}${/}3.txt
  ${U2}=  UMA Get ID Token From Response  ${U2}
  Set Global Variable  ${UB_TK}  ${U2}
  [Return]  ${id_token}

User A, User B OK
  ${rptA}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${WPS_PATH_PREFIX}/?service=WPS&version=1.0.0&request=GetCapabilities  ${WELL_KNOWN_PATH}  ${USERA}  ${PASSWORD_USERS}
  Log to Console  ${rptA}
  ${validation}=  WPS Get Capabilities  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${rptA}
  Status Should Be  200  ${validation}
  ${rptB}=  UMA_Flow2.UMA Flow Setup  ${UM_BASE_URL}  hola  /ades${WPS_PATH_PREFIX}/?service=WPS&version=1.0.0&request=GetCapabilities  ${WELL_KNOWN_PATH}  ${USERB}  ${PASSWORD_USERS}
  ${validation}=  WPS Get Capabilities  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${rptB}
  Status Should Be  200  ${validation}

PDP Modify Deny
  ${data} =  Evaluate  {"name":"Job1","description":"Status for job","config":{"resource_id":${RES_ID_JOB1},"rules":[{"OR":[{"EQUAL":{"userName":"UserA"}},{"EQUAL":{"userName":"UserB"}},{"EQUAL":{"userName":"admin"}}]}]},"scopes":["protected_access"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UB_TK}
  ${response}=  builtIn.Run Keyword If  "${POLICY_ID_JOB1}"!=""  Post Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}  json=${data}
  builtIn.Run Keyword If  "${POLICY_ID_JOB1}"!=""  Status Should Be  401  ${response}
  

PDP Modify Policy
  ${data} =  Evaluate  {"name":"Job1","description":"Status for job modified","config":{"resource_id":${RES_ID_JOB1},"rules":[{"OR":[{"EQUAL":{"userName":"UserA"}},{"EQUAL":{"userName":"UserB"}},{"EQUAL":{"userName":"admin"}}]}]},"scopes":["protected_access"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}  json=${data}
  Status Should Be  200  ${response}
  ${data} =  Evaluate  {"name":"Proc1","description":"Execution of Proc1","config":{"resource_id":${RES_ID_PROC2},"rules":[{"OR":[{"EQUAL":{"userName":"UserA"}},{"EQUAL":{"userName":"UserB"}},{"EQUAL":{"userName":"admin"}}]}]},"scopes":["protected_access"]}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID_PROC2}  headers=${headers}  json=${data}
  Status Should Be  200  ${response}

PDP UserB Status Success
  [Arguments]  ${tkn}
  ${ticket}=  API_PROC Check Job Status for Ticket  ${UM_BASE_URL}  ${LOCATION}  ${tkn}
  ${access_token}=  UMA_Flow2.UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${a}=  API_PROC Check Job Status Success  ${UM_BASE_URL}  ${LOCATION}  ${access_token}
  Status Should Be  200  ${a}  

PDP UserB Execution Success
  ${resp}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UB_TK}
  ${ticketB}=  UMA_Flow2.UMA Get Ticket From Response  ${resp}
  ${rptB}=  UMA_Flow2.UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticketB}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  #   User B attempts to execute Proc1. Unauthorized.
  ${validation}=  API_PROC Execute Process  ${UM_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${rptB}
  Status Should Be  201  ${validation}

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
  ${resp}=  Get Request  pep  /ades${path_prefix}/processes  headers=${headers}
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


API_PROC Check Job Status for Ticket
  [Arguments]  ${base_url}  ${location}  ${token}
  ${loc}=  Fetch From Right  ${location}  nip.io/
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${resp}=  Get Request  pep  /ades/${loc}  headers=${headers}
  ${ticket}=  UMA_Flow2.UMA Get Ticket From Response  ${resp}
  [return]  ${ticket}


API_PROC Check Job Status Success
  [Arguments]  ${base_url}  ${location}  ${token}
  ${loc}=  Fetch From Right  ${location}  nip.io/
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  FOR  ${index}  IN RANGE  2
    Sleep  30  Loop wait for processing execution completion
    ${resp}=  Get Request  pep  /ades/${loc}  headers=${headers}
    Exit For Loop If  "${resp}" == "<Response [401]>"
    Status Should Be  200  ${resp}
    ${status}=  Set Variable  ${resp.json()["status"]}
    Exit For Loop If  "${status}" != "running"
  END
  [return]  ${resp}
PEP Register Job1
  ${a}=  Run Process  python3  ${CURDIR}${/}insertJob1.py  ${ADES_BASE_URL}
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Job1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}Job1.txt
  Set Global Variable  ${RES_ID_JOB1}  ${resource_id}

PDP Register Job1
  [Arguments]  ${host}
  Create Session  pdp  ${host}:443  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Job1","description":"Job1 for Execution","config":{"resource_id":${RES_ID_JOB1},"rules":[{"AND":[{"EQUAL":{"userName":"UserA"}}]}]},"scopes":["protected_access"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Set Global Variable  ${POLICY_ID_JOB1}  ${json}
  Status Should Be  200  ${response}


API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token} 
  Create Session  pep  ${base_url}:443  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /ades${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  [return]  ${resp}

PEP Register Proc1
  ${a}=  Run Process  python3  ${CURDIR}${/}insertProc1.py  ${ADES_BASE_URL}
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
  ${data} =  Evaluate  {"name":"Proc1","description":"Proc1 UnDeploy","config":{"resource_id":${RES_ID_PROC1},"rules":[{"AND":[{"EQUAL":{"userName":"UserA"}}]}]},"scopes":["protected_access"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Set Global Variable  ${POLICY_ID_PROC1}  ${json}
  Status Should Be  200  ${response}

PDP Register Proc2
  [Arguments]  ${host}
  Create Session  pdp  ${host}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc2","description":"Proc1 Execute","config":{"resource_id":${RES_ID_PROC2},"rules":[{"AND":[{"EQUAL":{"userName":"UserA"}}]}]},"scopes":["protected_access"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Set Global Variable  ${POLICY_ID_PROC2}  ${json}
  Status Should Be  200  ${response}

API_PROC execute process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  pep  ${base_url}:443  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /ades${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  [Return]  ${resp}

API_PROC deploy process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  pep  /ades${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  [Return]  ${resp}

PEP Delete Resource
  [Arguments]  ${base_url}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${response}=  Delete Request  pep  /ades/resources/${RES_ID_ADES}  headers=${headers}
  ${ticket}=  UMA_Flow2.UMA Get Ticket From Response  ${response}
  ${rptB}=  UMA_Flow2.UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${ID_TOKEN}  ${C_ID_UMA}  ${C_SECRET_UMA}
  #   User B attempts to execute Proc1. Unauthorized.
  ${headers}=  Create Dictionary  authorization=Bearer ${rptB}
  ${response}=  Delete Request  pep  /ades/resources/${RES_ID_ADES}  headers=${headers}

PEP Register ADES 
  ${a}=  Run Process  python3  ${CURDIR}${/}insertADES.py  ${ADES_BASE_URL}
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}ADES.txt
  OperatingSystem.Remove File  ${CURDIR}${/}ADES.txt
  Set Global Variable  ${RES_ID_A}  ${resource_id}

WPS Get Capabilities Without Token
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=False
  ${resp}=  Get Request  ades  /ades${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}

WPS Get Capabilities
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${token}
  ${resp}=  Get Request  ades  /ades${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities  headers=${headers}
  [Return]  ${resp}

PDP Delete policies
  Create Session  pdp  ${UM_BASE_URL}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_PROC1}  headers=${headers}
  ${response}=  Delete Request  pdp  /pdp/policy/${POLICY_ID_PROC2}  headers=${headers}

Cleanup
  OperatingSystem.Remove File  ${CURDIR}${/}1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}2.txt
  OperatingSystem.Remove File  ${CURDIR}${/}3.txt
  OperatingSystem.Remove File  ${CURDIR}${/}location.txt

