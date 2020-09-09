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
${POLICY1_JSON}=  {"name":"NewPolicyDen","description":"Description for this new policy","config":{"resource_id":"123456789","rules":[{"AND":[{"EQUAL":{"userName":"admin"}}]},{"AND":[{"NOT":{"OR":[{"EQUAL":{"emails":[{'value':'mamuniz@test.com','primary':False}]}},{"EQUAL":{"nickName":"Admin"}}]},"EQUAL":{"displayName":"Default Admin User"}}]},{"EQUAL":{"groups":[{'value':'60B7','display':'Gluu Manager Group','type':'direct','ref':'https://test.10.0.2.15.nip.io/identity/restv1/scim/v2/Groups/60B7'}]}}]},"scopes":["Authorized"]}
${POLICY2_JSON}=   {"name":"NewPolicy","description":"Description for this new policy","config":{"resource_id":"12345678","rules":[{"AND":[{"EQUAL" : {"userName":"admin"}}]},{"AND":[{"NOT":{"OR":[{"EQUAL":{"emails":[{'value':'mamuniz@test.com','primary':False}]}},{"EQUAL":{"nickName":"Mami"}}]},"EQUAL":{"displayName":"Default Admin User"}}]},{"EQUAL":{"groups":[{'value':'60B7','display':'Gluu Manager Group','type':'direct','ref':'https://test.10.0.2.15.nip.io/identity/restv1/scim/v2/Groups/60B7'}]}}]},"scopes":["Authorized"]}
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/openid-configuration
${SCOPES}=  openid,permission,uma_protection
${RED_URI}=  
${REQ}=  grant_type=password&client_id=${C_ID_UMA}&client_secret=${C_SECRET_UMA}&username=admin&password=admin_Abcd1234#&scope=${SCOPES}&uri=
*** Test Cases ***
PDP Insert Policy Authenticated
  PDP Insert Policy  ${HOST}  ${PORT}  ${POLICY1_JSON}  ${POLICY2_JSON}  ${ID_TOKEN}
  PDP Get Other Token  ${C_ID_UMA}  ${C_SECRET_UMA}  ${WELL_KNOWN_PATH}  ${SCOPES}  ${RED_URI}  ${REQ}

PDP Permit Policy
  PDP Get Permit Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy ResourceID
  PDP Get Deny Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy Valid ResourceID Invalid Username
  PDP Get Deny Policy Username  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

*** Keywords ***
PDP Get Other Token
  [Arguments]  ${client_id}  ${client_secret}  ${well_known}  ${scopes}  ${redirect_uri}  ${req}
  ${headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded  Accept=application/json
  #${data}=  Evaluate  
  ${ep}=  PDP Get TokenEndpoint  ${well_known}
  Log to Console  ${ep}
  Log to Console  ${headers}
  Log to Console  ${req}
  Log to Console  ${CURDIR}
  Create Session  en  ${ep}  verify=False
  ${ey}=  Get Binary File  ${CURDIR}${/}bin.json
  Log to Console  ${ey}
  #${a}=  Run Process  bash  ${CURDIR}${/}rpt.sh  -S  -a  ${token_endpoint}  -t  ${ticket}  -i  ${client_id}  -p  ${client_secret}  -s  openid  -c  ${token}
  
  ${response}=   Post Request  en  /  headers=${headers}  data=${ey}
  Log to Console  ${response.text}
  Log to Console  ${response}

PDP Get TokenEndpoint
  [Arguments]  ${well_known} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

PDP Insert Policy
  [Arguments]  ${host}  ${port}  ${policy1}  ${policy2}  ${tkn}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${tkn}
  ${data} =  Evaluate  ${policy1}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- ${json} -----
  Status Should Be  200  ${response}
  ${data} =  Evaluate  ${policy2}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  ${policy_id}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- policy_id = ${policy_id} -----
  Status Should Be  200  ${response}
  

PDP Get Permit Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"admin","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"123456789","DataType":"string","IncludeInResult":True}]}]}}  json
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
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"admin","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"20248589","DataType":"string","IncludeInResult":True}]}]}}  json
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
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"test","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"20248583","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny