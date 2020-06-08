*** Settings ***
Documentation  Tests for the ADES WPS endpoint
Resource  ADES.resource
Library  XML

Suite Setup  WPS Suite Setup  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}


*** Variables ***
${WPS_PATH_PREFIX}=  /zoo


*** Test Cases ***
WPS service is alive
  WPS Get Capabilities Valid  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}

WPS available processes
  WPS Processes Are Expected  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${INITIAL_PROCESS_NAMES}


*** Keywords ***
WPS Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

WPS Get Capabilities
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}

WPS Get Capabilities Valid
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Get Capabilities  ${base_url}  ${path_prefix}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

WPS Get Process List
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Get Capabilities Valid  ${base_url}  ${path_prefix}
  ${processes}=  WPS Get Process Names From Response  ${resp}
  [Return]  @{processes}

WPS Get Process Names From Response
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

WPS Processes Are Expected
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True
