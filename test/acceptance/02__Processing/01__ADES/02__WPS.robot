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
${WPS_SERVICE_URL}=  ${ADES_BASE_URL}${WPS_PATH_PREFIX}
${USERNAME}=  UserA
${PASSWORD}=  defaultPWD
${ID_TOKEN}=
${ACCESS_TOKEN}=
${PEP_RESOURCE_PORT}=  31709


*** Test Cases ***
Initial Process List (TBD)
  # Initial Process List
  Log  Initial Process List is TBD

Attempt Unauthorised Access (TBD)
  # List Processes No Auth
  Log  List Processes No Auth is TBD


*** Keywords ***
Suite Setup
  # Init ID Token  ${USERNAME}  ${PASSWORD}
  # Init Resource Protection
  Log  Suite Setup is TBD

Suite Teardown
  # Client Save State
  Log  Suite Teardown is TBD

Init ID Token
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN}  ${id_token}

Init Resource Protection
  @{scopes}=  Create List  Authenticated
  ${resource_id}  Register Protected Resource  ${ADES_BASE_URL}:${PEP_RESOURCE_PORT}  ${WPS_PATH_PREFIX}  ${ID_TOKEN}  ADES WPS Service  ${scopes}
  Should Be True  $resource_id is not None
  ${resource_id}  Register Protected Resource  ${ADES_BASE_URL}:${PEP_RESOURCE_PORT}  ${WPS_JOB_MONITOR_ROOT}  ${ID_TOKEN}  ADES Job Monitor  ${scopes}
  Should Be True  $resource_id is not None

Initial Process List
  ${resp}=  List Processes
  @{processes}=  Get Process Names From Response  ${resp}
  Should Be True  $processes is not None
  Set Suite Variable  ${INITIAL_PROCESS_LIST}  ${processes}

List Processes
  ${resp}  ${access_token} =  WPS Get Capabilities  ${WPS_SERVICE_URL}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}

List Processes No Auth
  ${resp}  ${access_token} =  WPS Get Capabilities  ${WPS_SERVICE_URL}
  Status Should Be  401  ${resp}
  Should Be True  $access_token is None
  [Return]  ${resp}

Get Process Names From Response
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
