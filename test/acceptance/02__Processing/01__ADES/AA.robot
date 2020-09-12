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
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate


*** Test Cases ***
WPS Execution Protection
  ADES Execution Protection  ${HOST}  ${PORT}
WPS Deploy and Undeploy Application
  ADES Deploy Protection  ${HOST}  ${PORT}

*** Keywords ***
ADES Deploy Protection
  [Arguments]  ${host}  ${port}
  #UserA deploy blablalba
  #Register resource Proc1
  #Regiister policy Proc1 rule name 
  PDP Insert Policy Proc1  ${HOST}  ${PORT}
  #UserA undeploy blablalah
  #Register resource Proc1Un
  PDP Insert Policy Proc1U  ${HOST}  ${PORT}
  #Regiister policy Proc1Un rule name
  #UserB Deny
  WPS Validate Policy Deny UserB  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

ADES Execution Protection
  #UserA execute Process
  #Register Job1

API_PROC execute process For Job
  
  ${location}=  API_PROC Execute Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${RPT_TOKEN}
  Sleep  3  Waiting for process execution to start
  ${job_id}=  API_PROC Get Job ID From Location  ${location}
  OperatingSystem.Create File  ${CURDIR}${/}Job1.txt  ${job_id}
  PDP Insert Resource
  API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}  ${UA_TK}


API_PROC Execute Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}
  [Return]  ${resp.headers["Location"].split("${base_url}")[-1]}

Validate Execution
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

PEP Modify Resource
  Create Session  pep  ${host}:${port}/pep/resources/${RES_ID_ADES}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"reverse_match_url": "/"}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response

WPS Validate Policy Deny UserB
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserB","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":20,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"public","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_PROC1U},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny

PDP Insert Resource
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  #${myresp}=  Get Request  pdp  /pep/resources/ADES  headers=${headers}
  Log to Console  ${CURDIR}${/}setup.sh
  Log to Console  ${UA_TK}
  ${a}=  Run Process  python3  ${CURDIR}${/}test.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Proc1.txt
  ${resource_id_U}=  OperatingSystem.Get File  ${CURDIR}${/}Proc1U.txt
  Log to Console  ${resource_id} 
  Log to Console  ${resource_id_U} 
  Set Global Variable  ${RES_ID_PROC1}  ${resource_id}
  Set Global Variable  ${RES_ID_PROC1U}  ${resource_id_U}

PDP Insert Policy Proc1
  [Arguments]  ${host}  ${port}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc1","description":"Proc1 Deploy","config":{"resource_id":${RES_ID_PROC1},"rules":""},"scopes":["public"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- ${json} -----
  Status Should Be  200  ${response}
  Set Global Variable  ${POLICY_ID_PROC1}  ${json}

PDP Insert Policy Proc1U
  [Arguments]  ${host}  ${port}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Proc1U","description":"Proc1 UnDeploy","config":{"resource_id":${RES_ID_PROC1U},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}},{"EQUAL":{"user_name":"UserA"}}]}]},"scopes":["public"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Log to Console  ----- ${json} -----
  Status Should Be  200  ${response}
  Set Global Variable  ${POLICY_ID_PROC1U}  ${json}
 

Modify Policy
  ${data} =  Evaluate  {"name":"Proc1","description":"Description for this new policychanged","config":{"resource_id":${RES_ID_ADES},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}}]},{"OR":[{"EQUAL":{"user_name":"UserA"}},{"EQUAL":{"user_name":"UserB"}},{"EQUAL":{"user_name":"admin"}}]}]},"scopes":["Authorized"]}
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${response}=  Post Request  pdp  /pdp/policy/${POLICY_ID}  headers=${headers}  json=${data}
  Status Should Be  200  ${response}