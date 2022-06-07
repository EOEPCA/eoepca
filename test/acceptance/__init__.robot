*** Settings ***
Documentation  EOEPCA system-level tests
Suite Setup  EOEPCA Suite Setup

*** Keywords ***
EOEPCA Suite Setup
  Set Global Variable  ${UM_BASE_URL}  https://auth.${PUBLIC_HOSTNAME}
  Set Global Variable  ${DUMMY_SERVICE_HOSTNAME}  dummy-service.${PUBLIC_HOSTNAME}
  Set Global Variable  ${DUMMY_PEP_AUTH_HOSTNAME}  dummy-service-pep.${PUBLIC_HOSTNAME}
  Set Global Variable  ${DUMMY_SERVICE_RESOURCES_API_URL}  http://dummy-service-pepapi.${PUBLIC_HOSTNAME}
  Set Global Variable  ${ADES_BASE_URL}  http://ades.${PUBLIC_HOSTNAME}
  Set Global Variable  ${ADES_RESOURCES_API_URL}  http://ades-pepapi.${PUBLIC_HOSTNAME}
  Set Global Variable  ${RPT_TOKEN}  0
  Set Global Variable  ${USER_A_NAME}  eric
  Set Global Variable  ${USER_A_PASSWORD}  defaultPWD
  Set Global Variable  ${USER_B_NAME}  alice
  Set Global Variable  ${USER_B_PASSWORD}  defaultPWD
  Set Global Variable  ${USER_C_NAME}  bob
  Set Global Variable  ${USER_C_PASSWORD}  defaultPWD
  Set Global Variable  ${CATALOGUE_BASE_URL}  https://resource-catalogue.${PUBLIC_HOSTNAME}
  Set Global Variable  ${USER_PREFIX}  develop-user
