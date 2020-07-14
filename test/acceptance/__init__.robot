*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${ADES_BASE_URL}  http://ades.test.185.52.192.60.nip.io
  Set Global Variable  ${RPT_TOKEN}  0
