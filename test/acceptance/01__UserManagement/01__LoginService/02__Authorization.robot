*** Settings ***
Documentation  Tests for access authorization
Library  RequestsLibrary
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown

*** Variables ***


*** Test Cases ***

Authorized Access
  ${id_token}=  Get ID Token  ${USER_A_NAME}  ${USER_A_PASSWORD}
  Should Not Be Empty  ${id_token}
  Create Session  session  https://${DUMMY_SERVICE_HOSTNAME}  verify=False
  ${headers}=  Create Dictionary  X-User-Id=${id_token}
  ${resp}=  GET On Session  session  /ericspace  headers=${headers}  expected_status=any
  Status Should Be  200

Unauthorized Access
  Create Session  session  https://${DUMMY_SERVICE_HOSTNAME}  verify=False
  ${resp}=  GET On Session  session  /ericspace  expected_status=any
  Status Should Be  401

Forbidden Access
  ${id_token}=  Get ID Token  ${USER_B_NAME}  ${USER_B_PASSWORD}
  Should Not Be Empty  ${id_token}
  Create Session  session  https://${DUMMY_SERVICE_HOSTNAME}  verify=False
  ${headers}=  Create Dictionary  X-User-Id=${id_token}
  ${resp}=  GET On Session  session  /ericspace  headers=${headers}  expected_status=any
  Status Should Be  403

*** Keywords ***

Suite Setup
  Log  Suite Setup  DEBUG

Suite Teardown
  Client Save State
