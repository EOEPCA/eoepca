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
  User C KO
  #UserA and UserB attempts to perform a GetCapabilities
  User A, User B OK
  OperatingSystem.Remove File  ${CURDIR}${/}1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}2.txt
  OperatingSystem.Remove File  ${CURDIR}${/}3.txt

*** Keywords ***
User A, User B OK
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

User C KO
  ${resp}=  WPS Get Capabilities Without Token  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}
  ${ticket}=  UMA Get Ticket From Response  ${resp}
  #Check ticket against UMA and get Unauthorized
  ${rpt}=  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  NA  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${validation}=  WPS Get Capabilities  ${UM_BASE_URL}  ${WPS_PATH_PREFIX}  ${rpt}
  Status Should Be  401  ${validation}

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









