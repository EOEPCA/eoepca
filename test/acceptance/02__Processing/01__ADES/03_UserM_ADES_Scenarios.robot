*** Settings ***
Documentation  Tests for the ADES OGC WPS endpoint
# Resource  ADES.resource
# Library  OperatingSystem
# Library  String
# Library  Process
Library  RequestsLibrary
Library  Collections
Library  XML
# Library  ./DemoClient.py  ${UM_BASE_URL}
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${WPS_JOB_MONITOR_ROOT}=  /watchjob
${WPS_PATH_PREFIX}=  /zoo
${WPS_SERVICE_URL}=  ${ADES_BASE_URL}
${PDP_BASE_URL}=  http://test.185.52.193.87.nip.io/pdp
${ADES_RESOURCES_API_URL}=  http://ades.resources.185.52.193.87.nip.io/
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
  User B Unauthorized Undeploy
  User B Unauthorized Policy Change

#Application Sharing
#  User A Authorized Application Policy Change
#  User B Authorized Execution
#  User B Authorized Undeploy
  
Protected Application Execution
  User A Deploys Proc1
  User A Executes Proc1
#  User B Unauthorized Executes Proc2
#  User B Unauthorized Status Job1
#  User A Authorized Status Proc1
  
#Execution Status Sharing
#  User A Authorized Status Policy Change
#  User B Authorized Status Job1

*** Keywords ***
Suite Setup
  Init ID Token UserA  ${USERNAME}  ${PASSWORD}
  Init ID Token UserB  ${USERNAME_B}  ${PASSWORD}
  Init Resource Protection

Suite Teardown
  Client Save State

Init ID Token UserA
  [Arguments]  ${username}  ${password}
  ${id_token}=  DemoClient.Get ID Token  ${username}  ${password}
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

List Processes
  ${resp}  ${access_token} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${ID_TOKEN_USER_A}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}

List Processes No Auth
  ${resp}  ${access_token} =  Proc List Processes  ${WPS_SERVICE_URL}/${USERNAME}/wps3
  Status Should Be  401  ${resp}
  Should Be True  $access_token is None
  [Return]  ${resp}

User A Deploys Proc1
  #@{scopes}=  Create List  protected_access
  ${r}  ${access_token}=  DemoClient.Proc Deploy App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  ${CURDIR}/data${/}app-deploy-body.json  ${ID_TOKEN_USER_A}
  ${resource_id}  Register Protected Resource  ${ADES_RESOURCES_API_URL}  /UserA/watchjob/processes/UndeployProcess/  ${ID_TOKEN_USER_A}  ADES Undeploy  ${scopes}
  Set Global Variable  ${UNDEPLOY_R_ID}  ${resource_id}

User B Unauthorized Undeploy
  ${r}  ${access_token}=  DemoClient.Proc Undeploy App  ${WPS_SERVICE_URL}/${USERNAME}/watchjob  UndeployProcess/  ${ID_TOKEN_USER_B}

User B Unauthorized Policy Change
  ${ow}=  Get Ownership Id  ${ID_TOKEN_USER_B}
  ${data}=  Evaluate  {"name":"UPDATE DENY","description":"modified","config":{"resource_id":${UNDEPLOY_R_ID},"rules":[{"OR":[{ "EQUAL" : { "uid" : "${ow}"}},{ "EQUAL" : { "uid" : "${ow}"}}]}]},"scopes":["protected_access"]}
  ${resp}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${UNDEPLOY_R_ID}  ${ID_TOKEN_USER_B}
  #Status Should Be  401  ${resp}

User A Executes Proc1
  ${r}  ${access_token}  ${location}=  Proc Execute App  ${WPS_SERVICE_URL}/${USERNAME}/wps3  DeployProcess  ${CURDIR}/data${/}app-execute-body.json  ${ID_TOKEN_USER_A}