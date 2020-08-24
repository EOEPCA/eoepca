*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${UM_BASE_URL}  https://eoepca-dev.deimos-space.com
  Set Global Variable  ${ADES_BASE_URL}  http://eoepca-dev.deimos-space.com:30010
  Set Global Variable  ${RPT_TOKEN}  0
