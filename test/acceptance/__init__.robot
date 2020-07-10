*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${ADES_BASE_URL}  http://test.10.0.2.15.nip.io:31707
  Set Global Variable  ${RPT_TOKEN}  0
