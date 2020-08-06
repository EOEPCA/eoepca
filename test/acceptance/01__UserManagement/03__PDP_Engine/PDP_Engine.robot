*** Settings ***
Documentation  Tests for the UMA Flow
Library  Collections
Library  RequestsLibrary
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary

*** Variables ***
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate

*** Test Cases ***
PDP Permit Policy
  PDP Get Permit Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy ResourceID
  PDP Get Deny Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy Valid ResourceID Invalid Username
  PDP Get Deny Policy Username  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

*** Keywords ***
PDP Get Permit Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user-id","Value":"admin","DataType":"string","IncludeInResult":"true"},{"AttributeId":"claim-token","Value":"js3...","DataType":"string","IncludeInResult":"true"}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"20248583","DataType":"string","IncludeInResult":"true"}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

PDP Get Deny Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user-id","Value":"admin","DataType":"string","IncludeInResult":"true"},{"AttributeId":"claim-token","Value":"js3...","DataType":"string","IncludeInResult":"true"}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"202485839","DataType":"string","IncludeInResult":"true"}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny

PDP Get Deny Policy Username
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user-id","Value":"test","DataType":"string","IncludeInResult":"true"},{"AttributeId":"claim-token","Value":"js3...","DataType":"string","IncludeInResult":"true"}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"20248583","DataType":"string","IncludeInResult":"true"}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny