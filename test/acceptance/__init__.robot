*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${UM_BASE_URL}  https://test.${PUBLIC_HOSTNAME}
  Set Global Variable  ${ADES_BASE_URL}  http://ades.test.${PUBLIC_HOSTNAME}
  Set Global Variable  ${RPT_TOKEN}  0
