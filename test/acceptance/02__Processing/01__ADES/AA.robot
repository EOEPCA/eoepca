*** Settings ***
Documentation  Tests for the ADES WPS endpoint
Resource  ADES.resource
Library  XML
Library  Process
Library  OperatingSystem
Library  String



*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${RESOURCE}=  {"resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES"}
${POLICY1_JSON}=  {"name":"Proc1","description":"Description for this new policy","config":{"resource_id":${RES_ID},"rules":[{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"admin"}},{"EQUAL":{"scopes":"Authorized"}}]}]},"scopes":["public"]}
${POLICY2_JSON}=  {"name":"Proc2","description":"Description for this new policy","config":{"resource_id":${RES_ID},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}}]},{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}


*** Test Cases ***
WPS Set Up UseCase
  WPS AA1  ${HOST}  ${PORT}  ${POLICY1_JSON}  ${POLICY2_JSON}


*** Keywords ***
WPS AA1
  [Arguments]  ${host}  ${port}  ${json1}  ${json2} 
  #admin Register ADES scope 'public'
  
  PDP Insert Resource
  PDP Insert Policy  ${host}  ${port}  ${json1}  ${json2}
  #Try with user with no Authorization in scope: PERMIT
  WPS Validate Policy Permit  ${HOST}  443  pdp/policy/validate
  #admin Register ADES scope 'Authorized'
  #C deny, A/B permit

PEP Modify Resource
  Create Session  pep  ${host}:${port}/pep/resources/${RES_ID}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"reverse_match_url": "/"}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  

WPS Validate Policy Permit
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserA","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

PDP Insert Resource
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  #${myresp}=  Get Request  pdp  /pep/resources/ADES  headers=${headers}
  ${data} =  Evaluate  ${resource}
  Log to Console  ${CURDIR}${/}setup.sh
  Log to Console  ${UA_TK}
  ${a}=  Run Process  python3  ${CURDIR}${/}test.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}res.txt
  Log to Console  ${resource_id} Bietch
  Set Global Variable  ${RES_ID}  ${resource_id}
PDP Insert Policy
  [Arguments]  ${host}  ${port}  ${policy1}  ${policy2}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  ${policy1}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- ${json} -----
  Status Should Be  200  ${response}
  ${data} =  Evaluate  ${policy2}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  ${policy_id}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- policy_id = ${policy_id} -----
  Status Should Be  200  ${response}
