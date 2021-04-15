*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${UM_BASE_URL}  https://test.${PUBLIC_HOSTNAME}
  Set Global Variable  ${ADES_BASE_URL}  http://ades.test.${PUBLIC_HOSTNAME}
  Set Global Variable  ${RPT_TOKEN}  0
  ${USER_NAME_PREFIX}=  Set Variable  User
  Set Global Variable  ${USER_A_NAME}  ${USER_NAME_PREFIX}A
  Set Global Variable  ${USER_A_PASSWORD}  defaultPWD
  Set Global Variable  ${USER_B_NAME}  ${USER_NAME_PREFIX}B
  Set Global Variable  ${USER_B_PASSWORD}  defaultPWD
