*** Settings ***
Library  RequestsLibrary
Library  XML
Library  Collections

*** Test Cases ***
WPS is alive
  Check WPS DescribeProcess  http://localhost:7777  /zoo

OGC API Processes is alive
  Check OGC API Process  http://localhost:7777  /wps3

Available WPS processes
  @{processes}=  Get WPS Process List  http://localhost:7777  /zoo
  @{process_names}=  Create List
  Log  ${process_names}
  FOR  ${process}  IN  @{processes}
    ${name}=  Get Element  ${process}  Identifier
    Log  ${name.text}
    Append To List  ${process_names}  ${name.text}
  END
  @{expected}=  Create List  GetStatus  longProcess  eoepcaadesdeployprocess  eoepcaadesundeployprocess
  Lists Should Be Equal  ${process_names}  ${expected}  ignore_order=True

*** Keywords ***
Check WPS DescribeProcess
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  Status Should Be  200  ${resp}

Get WPS Process List
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  Status Should Be  200  ${resp}
  ${root}=  Parse XML  ${resp.text}
  @{processes}=  Get Elements  ${root}  ProcessOfferings/Process
  [Return]  @{processes}


Check OGC API Process
  [Arguments]  ${base_url}  ${path_prefix}
  ${headers}=  Create Dictionary  accept=application/json
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  Status Should Be  200  ${resp}

