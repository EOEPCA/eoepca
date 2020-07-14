*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${ADES_BASE_URL}  http://test.192.168.123.110.nip.io:31707
  Set Global Variable  ${RPT_TOKEN}  0
