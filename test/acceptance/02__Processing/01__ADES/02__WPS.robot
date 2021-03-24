*** Settings ***
Documentation  Tests for the ADES OGC WPS endpoint
Library  RequestsLibrary
Library  Collections
Library  XML
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${USERNAME}=  UserA
${PASSWORD}=  defaultPWD
${ADES_WORKSPACE}=  ${USERNAME}
${PROCESS_NAME}=  s-expression-0_0_2
${WPS_PATH_PREFIX}=  /${ADES_WORKSPACE}/zoo
${WPS_SERVICE_URL}=  ${ADES_BASE_URL}${WPS_PATH_PREFIX}
${ID_TOKEN}=
${ACCESS_TOKEN}=


*** Test Cases ***
Initial Process List
  Initial Process List

Attempt Unauthorised Access
  List Processes No Auth


*** Keywords ***
Suite Setup
  Init ID Token  ${USERNAME}  ${PASSWORD}

Suite Teardown
  Client Save State

Init ID Token
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN}  ${id_token}

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
