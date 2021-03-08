*** Settings ***
Documentation  Tests for the ADES OGC WPS endpoint
Library  RequestsLibrary
Library  Collections
Library  XML
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
#Suite Teardown  Suite Teardown


*** Variables ***
${WPS_JOB_MONITOR_ROOT}=  /watchjob
${WPS_PATH_PREFIX}=  /zoo
${WPS_SERVICE_URL}=  ${ADES_BASE_URL}
${PDP_BASE_URL}=  http://test.185.52.193.87.nip.io/pdp
${ADES_RESOURCES_API_URL}=  http://ades.resources.185.52.193.87.nip.io
${ADES_PEP_PROXY}=  http://ades.test.185.52.193.87.nip.io/
${USERNAME_B}=  UserB
${USERNAME}=  UserA
${PASSWORD}=  defaultPWD
${ID_TOKEN_USER_A}=
${ID_TOKEN_USER_B}=
${ACCESS_TOKEN}=
${PEP_RESOURCE_PORT}=  31709

*** Test Cases ***

Initial Process List
  List Processes

Attempt Unauthorised Access Process List
  List Processes No Auth

Protected Application Deployment
  User A Deploys Proc1
  # Manual Registration of Undeploy and Execute processes
  # <TBC>
  PEP Register Resource  /UserA/wps3/processes/s-expression-0_0_2  ADES Deploy
  PEP Register Resource  /UserA/wps3/processes/s-expression-0_0_2/jobs  ADES Execute
  # </TBC>
  User B Unauthorized Undeploy
  User B Unauthorized Policy Change
  
Protected Application Execution
  User A Deploys Proc1
  
  User A Executes Proc1
  # Manual Registration of Status Job processes
  # <TBC>
  #PEP Register Resource  ${LOCATION}  ADES Status Job
  # </TBC>
  User B Unauthorized Executes Proc2
  User B Unauthorized Status Job1
  User A Authorized Status Proc1

Execution Status Sharing
  User A Authorized Status Policy Change
  User B Authorized Status Job1

Application Sharing
  User A Authorized Application Policy Change
  User B Authorized Execution
  User B Authorized Undeploy

Clean Resources
  Sleep  5
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_A}
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_B}


*** Keywords ***

#######   SUITE SETUP

Suite Setup
  Init ID Token UserA  ${USERNAME}  ${PASSWORD}
  Init ID Token UserB  ${USERNAME_B}  ${PASSWORD}
  Init Resource Protection

Suite Teardown
  Client Save State

Init ID Token UserA
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN_USER_A}  ${id_token}
  
Init ID Token UserB
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN_USER_B}  ${id_token}

Init Resource Protection
  @{scopes}=  Create List  Authenticated
  ${resource_id}  Register Protected Resource  ${ADES_RESOURCES_API_URL}  /${USERNAME}  ${ID_TOKEN_USER_A}  ADES WPS Service  ${scopes}
  Should Be True  $resource_id is not None
  ${resource_id}  Register Protected Resource  ${ADES_RESOURCES_API_URL}  /${USERNAME}${WPS_JOB_MONITOR_ROOT}  ${ID_TOKEN_USER_A}  ADES Job Monitor  ${scopes}
  Should Be True  $resource_id is not None

  
#######   INITIAL PROCESS LIST

List Processes
  ${resp}  ${access_token} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${ID_TOKEN_USER_A}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}


#######   ATTEMPT UNAUTHORISED ACCESS PROCESS LIST

List Processes No Auth
  ${resp}  ${access_token} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3
  Status Should Be  401  ${resp}
  Should Be True  $access_token is None
  [Return]  ${resp}


#######   PROTECTED APPLICATION DEPLOYMENT

User A Deploys Proc1
  ${r}  ${access_token}=  Proc Deploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${CURDIR}/data${/}app-deploy-body.json  ${ID_TOKEN_USER_A}
  Status Should Be  201  ${r}

User B Unauthorized Undeploy
  ${r}  ${access_token}=  Proc Undeploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_2  ${ID_TOKEN_USER_B}
  Status Should Be  401  ${r}
  Should Be True  $access_token is None

User B Unauthorized Policy Change
  ${ow}=  Get Ownership Id  ${ID_TOKEN_USER_B}
  ${r_id}=  Get Resources Deploy UserA
  ${data}=  Evaluate  {'name':'UPDATE DENY','description':'modified','config':{'resource_id':'${r_id}','action':'view','rules':[{'OR':[{'EQUAL':{'id':'${ow}'}},{'EQUAL':{'id':'${ow}'}}]}]},'scopes':['protected_access']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${r_id}  ${ID_TOKEN_USER_B}
  ${validator}=  Convert To String  ${resp}
  Should Be Equal  ${validator}  401

  
#######   APPLICATION SHARING

User A Authorized Application Policy Change
  ${owb}=  Get Ownership Id  ${ID_TOKEN_USER_B}
  ${owa}=  Get Ownership Id  ${ID_TOKEN_USER_A}
  ${r_id}=  Get Resources Deploy UserA
  ${data}=  Evaluate  {'name':'Updated ADES Deploy','description':'modified','config':{'resource_id':'${r_id}','action':'view','rules':[{'OR':[{'EQUAL':{'id':'${owa}'}},{'EQUAL':{'id':'${owb}'}}]}]},'scopes':['protected_access']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${r_id}  ${ID_TOKEN_USER_A}
  ${r_id}=  Get Resources Execute UserA
  ${data}=  Evaluate  {'name':'Updated ADES Execute','description':'modified','config':{'resource_id':'${r_id}','action':'view','rules':[{'OR':[{'EQUAL':{'id':'${owa}'}},{'EQUAL':{'id':'${owb}'}}]}]},'scopes':['protected_access']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${r_id}  ${ID_TOKEN_USER_A}
 
User B Authorized Execution
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_2  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_B}
  #Set Global Variable  ${LOCATION}  ${location}
  Status Should Be  201  ${r}
  
User B Authorized Undeploy
  ${r}  ${access_token}=  Proc Undeploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_2  ${ID_TOKEN_USER_B}
  Status Should Be  200  ${r}
  
#######   PROTECTED APPLICATION EXECUTION
 User A Executes Proc2
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_22  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_A}
  Set Global Variable  ${LOCATION}  ${location}
  Status Should Be  201  ${r}

User A Executes Proc1
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_2  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_A}
  Set Global Variable  ${LOCATION}  ${location}
  Status Should Be  201  ${r}

User B Unauthorized Executes Proc2
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  s-expression-0_0_2  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_B}
  Status Should Be  401  ${r}

User B Unauthorized Status Job1
  ${r}  ${access_token}=  Proc Job Status  ${WPS_SERVICE_URL}  ${LOCATION}  ${ID_TOKEN_USER_B}
  Status Should Be  401  ${r}
  
User A Authorized Status Proc1
  Sleep  5
  ${r}  ${access_token}=  Proc Job Status  ${WPS_SERVICE_URL}  ${location}  ${ID_TOKEN_USER_A}
  Status Should Be  200  ${r}
  # FOR  ${index}  IN RANGE  40
  #   ${r}  ${access_token}=  Proc Job Status  ${WPS_SERVICE_URL}  ${LOCATION}  ${ID_TOKEN_USER_B}
  #   Status Should Be  200  ${r}
  #   Should Be True  $access_token is not None
  #   Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  #   ${status}=  Set Variable  ${r.json()["status"]}
  #   Exit For Loop If  "${status}" != "running"
  # END

    
#######   EXECUTION STATUS SHARING

User A Authorized Status Policy Change
  ${owb}=  Get Ownership Id  ${ID_TOKEN_USER_B}
  ${owa}=  Get Ownership Id  ${ID_TOKEN_USER_A}
  ${r_id}=  Get Resources Status UserA
  ${data}=  Evaluate  {'name':'Updated ADES Status Job','description':'modified','config':{'resource_id':'${r_id}','action':'view','rules':[{'OR':[{'EQUAL':{'id':'${owa}'}},{'EQUAL':{'id':'${owb}'}}]}]},'scopes':['protected_access']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${r_id}  ${ID_TOKEN_USER_A}

User B Authorized Status Job1
  Sleep  5
  ${r}  ${access_token}=  Proc Job Status  ${WPS_SERVICE_URL}  ${location}  ${ID_TOKEN_USER_B}
  Status Should Be  200  ${r}

  
#######   OTHER KEYWORDS

PEP Register Resource
  [Arguments]  ${icon_uri}  ${name}
  @{scopes}=  Create List  protected_access
  ${resource_id}  Register Protected Resource  ${ADES_RESOURCES_API_URL}  ${icon_uri}  ${ID_TOKEN_USER_A}  ${name}  ${scopes}
  [Return]  ${resource_id}

Get Resources Deploy UserA
  ${res_id}=  Get Resource By Name  ${ADES_RESOURCES_API_URL}  ADES Deploy  ${ID_TOKEN_USER_A}
  [Return]  ${res_id}

Get Resources Execute UserA
  ${res_id}=  Get Resource By Name  ${ADES_RESOURCES_API_URL}  ADES Execute  ${ID_TOKEN_USER_A}
  [Return]  ${res_id}

Get Resources Status UserA
  ${res_id}=  Get Resource By Name  ${ADES_RESOURCES_API_URL}  s-expression-0_0_2  ${ID_TOKEN_USER_A}
  [Return]  ${res_id}