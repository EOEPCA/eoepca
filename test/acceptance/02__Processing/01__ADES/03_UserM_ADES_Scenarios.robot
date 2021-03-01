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
${ADES_RESOURCES_API_URL}=  http://test.185.52.193.87.nip.io/secure
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
  
#Protected Application Deployment
#  User A Deploys Proc1 
#  User B Unauthorized Undeploy
#  User B Unauthorized Policy Change

#Application Sharing
#  User A Authorized Application Policy Change
#  User B Authorized Execution
#  User B Authorized Undeploy
  
#Protected Application Execution
#  User A Deploys Proc1
#  User A Executes Proc1
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