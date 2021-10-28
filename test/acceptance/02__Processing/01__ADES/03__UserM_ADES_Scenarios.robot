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
${PDP_BASE_URL}=  ${UM_BASE_URL}/pdp
${USERNAME}=  ${USER_A_NAME}
${PASSWORD}=  ${USER_A_PASSWORD}
${USERNAME_B}=  ${USER_B_NAME}
${PASSWORD_B}=  ${USER_B_PASSWORD}
${ID_TOKEN_USER_A}=
${ID_TOKEN_USER_B}=
${ACCESS_TOKEN}=
${PDP_URL}=  31709
${PROCESS_NAME}=  snuggs-0_3_0

*** Test Cases ***

Initial Process List
  List Processes

Attempt Unauthorised Access Process List
  List Processes No Auth

Protected Application Deployment
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_A}  ${PROCESS_NAME}
  User A Deploys Proc1
  # Manual Registration of Undeploy and Execute processes
  # <TBC>
  PEP Register Resource  /${USERNAME}/wps3/processes/${PROCESS_NAME}  ADES Deploy
  PEP Register Resource  /${USERNAME}/wps3/processes/${PROCESS_NAME}/jobs  ADES Execute
  # </TBC>
  User B Unauthorized Undeploy
  User B Unauthorized Policy Change
  
Protected Application Execution
  User A Deploys Proc1
  # Reset Resource Policy  ${ADES_RESOURCES_API_URL}  ${PDP_BASE_URL}  ${ID_TOKEN_USER_A}  /${USERNAME}/wps3/processes/${PROCESS_NAME}
  User A Executes Proc1
  # Manual Registration of Status Job processes
  # <TBC>
  PEP Register Resource  ${LOCATION}  ADES Status Job
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
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_A}  ADES Deploy
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_A}  ADES Execute
  Clean Owner Resources  ${ADES_RESOURCES_API_URL}  ${ID_TOKEN_USER_A}  ADES Status Job


*** Keywords ***

#######   SUITE SETUP

Suite Setup
  Init ID Token UserA  ${USERNAME}  ${PASSWORD}
  Init ID Token UserB  ${USERNAME_B}  ${PASSWORD_B}
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
  #Should Be True  $resource_id is not None
  ${resource_id}  Register Protected Resource  ${ADES_RESOURCES_API_URL}  /${USERNAME}${WPS_JOB_MONITOR_ROOT}  ${ID_TOKEN_USER_A}  ADES Job Monitor  ${scopes}
  #Should Be True  $resource_id is not None

  
#######   INITIAL PROCESS LIST

List Processes
  ${resp}  ${access_token}  @{processes} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${ID_TOKEN_USER_A}
  Should Be Equal As Integers  200  ${resp.status_code}
  #Should Be True  $access_token is not None
  #Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}  @{processes}


#######   ATTEMPT UNAUTHORISED ACCESS PROCESS LIST

List Processes No Auth
  ${resp}  ${access_token}  @{processes} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3
  Should Be Equal As Integers  401  ${resp.status_code}
  Should Be True  $access_token is None
  [Return]  ${resp}  @{processes}


#######   PROTECTED APPLICATION DEPLOYMENT

User A Deploys Proc1
  ${r}  ${access_token}=  Proc Deploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${CURDIR}/data${/}app-deploy-body-cwl.json  ${ID_TOKEN_USER_A}
  Should Be Equal As Integers  201  ${r.status_code}

User B Unauthorized Undeploy
  ${r}  ${access_token}=  Proc Undeploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}  ${ID_TOKEN_USER_B}
  Should Be Equal As Integers  403  ${r.status_code}
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
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_B}
  #Set Global Variable  ${LOCATION}  ${location}
  Should Be Equal As Integers  201  ${r.status_code}
  
User B Authorized Undeploy
  ${r}  ${access_token}=  Proc Undeploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}  ${ID_TOKEN_USER_B}
  Should Be Equal As Integers  200  ${r.status_code}
  
#######   PROTECTED APPLICATION EXECUTION
 User A Executes Proc2
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}2  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_A}
  Set Global Variable  ${LOCATION}  ${location}
  Should Be Equal As Integers  201  ${r.status_code}

User A Executes Proc1
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_A}
  Set Global Variable  ${LOCATION}  ${location}
  Should Be Equal As Integers  201  ${r.status_code}

User B Unauthorized Executes Proc2
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${PROCESS_NAME}  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_B}
  Should Be Equal As Integers  403  ${r.status_code}

User B Unauthorized Status Job1
  ${r}  ${access_token}  ${status}=  Proc Job Status  ${WPS_SERVICE_URL}  ${LOCATION}  ${ID_TOKEN_USER_B}
  Should Be Equal As Integers  403  ${r.status_code}
  
User A Authorized Status Proc1
  Sleep  5
  ${r}  ${access_token}  ${status}=  Proc Job Status  ${WPS_SERVICE_URL}  ${location}  ${ID_TOKEN_USER_A}
  Should Be Equal As Integers  200  ${r.status_code}
  # FOR  ${index}  IN RANGE  40
  #   ${r}  ${access_token}  ${status}=  Proc Job Status  ${WPS_SERVICE_URL}  ${LOCATION}  ${ID_TOKEN_USER_B}
  #   Should Be Equal As Integers  200  ${r.status_code}
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
  ${r}  ${access_token}  ${status}=  Proc Job Status  ${WPS_SERVICE_URL}  ${location}  ${ID_TOKEN_USER_B}
  Should Be Equal As Integers  200  ${r.status_code}

  
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
  ${res_id}=  Get Resource By Name  ${ADES_RESOURCES_API_URL}  ${PROCESS_NAME}  ${ID_TOKEN_USER_A}
  [Return]  ${res_id}