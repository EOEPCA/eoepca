*** Settings ***
Library  RequestsLibrary
Library  XML
Library  Collections


*** Variables ***
${BASE_URL}=  http://localhost:7777
${WPS_PATH_PREFIX}=  /zoo
${API_PATH_PREFIX}=  /wps3
@{EXPECTED_WPS_PROCESS_NAMES}=  GetStatus  longProcess  eoepcaadesdeployprocess  eoepcaadesundeployprocess


*** Test Cases ***
WPS is alive
  Check WPS DescribeProcess  ${BASE_URL}  ${WPS_PATH_PREFIX}

OGC API Processes is alive
  Check OGC API Process  ${BASE_URL}  ${API_PATH_PREFIX}

Available WPS processes
  WPS Processes Are Expected  ${BASE_URL}  ${WPS_PATH_PREFIX}  ${EXPECTED_WPS_PROCESS_NAMES}


*** Keywords ***
WPS Describe Process
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}

Check WPS DescribeProcess
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Describe Process  ${base_url}  ${path_prefix}
  Status Should Be  200  ${resp}

Check OGC API Process
  [Arguments]  ${base_url}  ${path_prefix}
  ${headers}=  Create Dictionary  accept=application/json
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  Status Should Be  200  ${resp}

WPS Process List
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Describe Process  ${base_url}  ${path_prefix}
  Status Should Be  200  ${resp}
  @{processes}=  Processes From GetCapabilities  ${resp.text}
  [Return]  @{processes}

Processes From GetCapabilities
  [Arguments]  ${xml}
  ${root}=  Parse XML  ${xml}
  @{processes}=  Get Elements  ${root}  ProcessOfferings/Process
  [Return]  @{processes}

WPS Processes Are Expected
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}
  @{processes}=  WPS Process List  ${base_url}  ${path_prefix}
  @{process_names}=  Create List
  FOR  ${process}  IN  @{processes}
    ${name}=  Get Element  ${process}  Identifier
    Log  ${name.text}
    Append To List  ${process_names}  ${name.text}
  END
  Lists Should Be Equal  ${process_names}  ${expected_process_names}  ignore_order=True
