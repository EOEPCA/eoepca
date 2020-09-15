*** Settings ***
Documentation  Tests for the ADES WPS endpoint
Resource  ADES.resource
Library  XML
Library  Process
Suite Setup  WPS Suite Setup  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${RPT_TOKEN}

*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${RESOURCE}=  {"resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES"}


*** Test Cases ***
WPS Protection as a Service
  WPS Protection  ${HOST}  ${PORT}  ${POLICY1_JSON}  ${POLICY2_JSON}

WPS service is alive
  WPS Get Capabilities Valid  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${RPT_TOKEN}

WPS service is protected
  WPS Get Capabilities Invalid  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}
  
WPS available processes
  WPS Processes Are Expected  ${ADES_BASE_URL}  ${WPS_PATH_PREFIX}  ${INITIAL_PROCESS_NAMES}  ${RPT_TOKEN}

Policy Ownership and Policy Updates
  PDP Modify Deny
  PDP Modify Policy
  PDP UserB Status Success  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  PDP UserB Execution Success  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

*** Keywords ***
WPS Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}  ${token}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

WPS Protection
  [Arguments]  ${host}  ${port}  ${json1}  ${json2} 
  #admin Register ADES scope 'public'
  #PDP Insert Resource
  PDP Insert Policy  ${host}  ${port}  ${json1}  ${json2}
  #admin Register ADES scope 'Authorized'
  #Try with user with no Authorization in scope: PERMIT
  WPS Validate Policy Permit UserC  ${HOST}  443  pdp/policy/validate
  Modify Policy
  #C deny, A/B permit
  WPS Validate Policy Deny UserC  ${HOST}  443  pdp/policy/validate
  WPS Validate Policy Permit UserA, UserB  ${HOST}  443  pdp/policy/validate

PEP Modify Resource
  Create Session  pep  ${host}:${port}/pep/resources/${RES_ID_ADES}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"reverse_match_url": "/"}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response

WPS Validate Policy Deny UserC
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserC","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"public","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_ADES},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny

WPS Validate Policy Permit UserC
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserC","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"public","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_ADES},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

WPS Validate Policy Permit UserA, UserB
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserA","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_ADES},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserB","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_ADES},"DataType":"string","IncludeInResult":True}]}]}}  json
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

PDP Insert Resource
  ${a}=  Run Process  python3  ${CURDIR}${/}insRes.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}res.txt
  Set Global Variable  ${RES_ID_ADES}  ${resource_id}

PDP Insert Policy
  [Arguments]  ${host}  ${port}  ${policy1}  ${policy2}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc1","description":"Description for this new policy","config":{"resource_id":${RES_ID_ADES},"rules":""},"scopes":["public"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- ${json} -----
  Status Should Be  200  ${response}
  Set Global Variable  ${POLICY_ID}  ${json}

Modify Policy
  ${data} =  Evaluate  {"name":"Proc1","description":"Description for this new policychanged","config":{"resource_id":${RES_ID_ADES},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}}]},{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"UserB"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID}  headers=${headers}  json=${data}
  Log to Console  ${response.text}
  ${policy_id}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}
  
PDP Modify Policy Deny
  ${data} =  Evaluate  {"name":"Job1","description":"Status for job","config":{"resource_id":${RES_ID_JOB1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}}]},{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"UserB"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UB_TK}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}  json=${data}
  Log to Console  ${response.text}
  Status Should Be  401  ${response}
  
PDP Modify Policy
  ${data} =  Evaluate  {"name":"Job1","description":"Status for job","config":{"resource_id":${RES_ID_JOB1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}}]},{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"UserB"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID_JOB1}  headers=${headers}  json=${data}
  Log to Console  ${response.text}
  ${policy_id}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}
  
PDP UserB Status Success
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserB","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_JOB1},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit
  
PDP UserB Execution Success
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserB","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_PROC1}},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

WPS Get Capabilities
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  authorization=Bearer ${token}
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities  headers=${headers}
  [Return]  ${resp}
  
WPS Get Capabilities Without Token
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}
  
WPS Get Capabilities Invalid
  [Arguments]  ${base_url}  ${path_prefix}
  ${resp}=  WPS Get Capabilities Without Token  ${base_url}  ${path_prefix}
  Status Should Be  401  ${resp}
  [Return]  ${resp}

WPS Get Capabilities Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  WPS Get Capabilities  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

WPS Get Process List
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  WPS Get Capabilities Valid  ${base_url}  ${path_prefix}  ${token}
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
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}  ${token}
  ${processes}=  WPS Get Process List  ${base_url}  ${path_prefix}  ${token}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True
