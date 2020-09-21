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
${POLICY1_JSON}=  {"name":"NewPolicy1","description":"Description for this new policy","config":{"resource_id":"202485831","rules":[{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"admin"}},{"EQUAL":{"scopes":"Authorized"}}]}]},"scopes":["Authorized"]}
${POLICY2_JSON}=  {"name":"NewPolicy2","description":"Description for this new policy","config":{"resource_id":"202485831","rules":[{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/openid-configuration
${SCOPES}=  openid,permission,uma_protection 
${REQ}=  grant_type=password&client_id=${C_ID_UMA}&client_secret=${C_SECRET_UMA}&username=admin&password=admin_Abcd1234#&scope=${SCOPES}&uri=

${RES}=  {"resource_scopes":[ "Authenticated"], "icon_uri":"/p", "name":"ADES"}
*** Test Cases ***

PDP Insert Policy Authenticated
  PDP Get Other Token  ${WELL_KNOWN_PATH}
  PDP Insert Policy  ${HOST}  ${PORT}  ${POLICY1_JSON}  ${POLICY2_JSON}

PDP Permit Policy
  PDP Get Permit Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy ResourceID
  PDP Get Deny Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy Valid ResourceID Invalid Username
  PDP Get Deny Policy Username  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  OperatingSystem.Remove File  ${CURDIR}${/}2.txt
  OperatingSystem.Remove File  ${CURDIR}${/}3.txt


  
*** Keywords ***

PDP Get Other Token
  [Arguments]  ${well_known}
  ${ep}=  PDP Get TokenEndpoint  ${well_known}
  ${a}=  Run Process  sh  ${CURDIR}${/}tkn.sh  -t  ${ep}  -i  ${C_ID_UMA}  -p  ${C_SECRET_UMA}
  ${U1}=  OperatingSystem.Get File  ${CURDIR}${/}2.txt
  ${U1}=  PDP Get Access Token From Response  ${U1}
  Set Global Variable  ${UA_TK}  ${U1}
  ${U2}=  OperatingSystem.Get File  ${CURDIR}${/}3.txt
  ${U2}=  PDP Get Access Token From Response  ${U2}
  Set Global Variable  ${UB_TK}  ${U2}

PDP Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token}

PDP Get TokenEndpoint
  [Arguments]  ${well_known} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

PDP Insert Policy
  [Arguments]  ${host}  ${port}  ${policy1}  ${policy2}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${data} =  Evaluate  ${policy1}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}
  ${data} =  Evaluate  ${policy2}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  ${policy_id}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}
  
#Validation
PDP Get Permit Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserA","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value": "202485831" ,"DataType":"string","IncludeInResult":True}]}]}}  json
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
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"admin","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"21345","DataType":"string","IncludeInResult":True}]}]}}  json
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
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"test","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"202485831","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny