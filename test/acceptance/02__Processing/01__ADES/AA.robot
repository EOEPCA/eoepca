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
API_PROC Deploy and Undeploy Application Protection
  ADES Deploy Protection  ${HOST}  ${PORT}
API_PROC Execution Protection
  ADES Execution Protection

*** Keywords ***
ADES Deploy Protection
  [Arguments]  ${host}  ${port}
  #UserA deploy Proc1
  #Register resource Proc1
  #Regiister policy Proc1 rule name 
  PDP Insert Resource
  PDP Insert Policy Proc1  ${HOST}  ${PORT}
  #UserA undeploy Proc1
  #Register resource Proc1Un
  PDP Insert Policy Proc1U  ${HOST}  ${PORT}
  #UserB Deny
  API_PROC Validate Policy Deny UserB  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

ADES Execution Protection
  #UserA execute Process
  #API_PROC execute process For Job
  #IF 500 error
  PEP Insert Job
  PDP Insert Policy Job1  ${HOST}  ${PORT}
  API_PROC Validate Execution UserA  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  API_PROC Deny Execution UserB  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

API_PROC execute process For Job
  ${location}=  API_PROC Location  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${UA_TK}
  Sleep  3  Waiting for process execution to start
  ${job_id}=  API_PROC Get Job ID From Location  ${location}
  OperatingSystem.Create File  ${CURDIR}${/}Job1.txt  ${job_id}
  PEP Insert Job
  PDP Insert Policy Job1  ${HOST}  ${PORT}
  API_PROC Validate Execution UserA  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  API_PROC Deny Execution UserB  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}  ${UA_TK}

API_PROC Location
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}
  [Return]  ${resp.headers["Location"].split("${base_url}")[-1]}

API_PROC Validate Execution UserA
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserA","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_JOB1},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

API_PROC Deny Execution UserB
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value":"UserB","DataType":"string","IncludeInResult":True},{"AttributeId":"num_acces","Value":6,"DataType":"int","IncludeInResult":True},{"AttributeId":"attemps","Value":5,"DataType":"int","IncludeInResult":True},{"AttributeId":"company","Value":"Deimos","DataType":"string","IncludeInResult":True},{"AttributeId":"system_load","Value":4,"DataType":"int","IncludeInResult":True},{"AttributeId":"scopes","Value":"Authorized","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":${RES_ID_JOB1},"DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}  
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny

PEP Insert Job
  Create Session  pdp  ${host}:${port}  verify=False
  ${a}=  Run Process  python3  ${CURDIR}${/}InsJob.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Job1R.txt
  Set Global Variable  ${RES_ID_JOB1}  ${resource_id}

PDP Insert Policy Job1
  [Arguments]  ${host}  ${port}
  Create Session  pdp  ${host}:${port}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${UA_TK}
  ${data} =  Evaluate  {"name":"Job1","description":"Job1 Execution","config":{"resource_id":${RES_ID_JOB1},"rules":[{"AND":[{"EQUAL":{"scopes":"Authorized"}},{"EQUAL":{"user_name":"UserA"}}]}]},"scopes":["public"]}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Status Should Be  200  ${response}
  Set Global Variable  ${POLICY_ID_JOB1}  ${json}


API_PROC Validate Policy Deny UserB
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
  ${a}=  Run Process  python3  ${CURDIR}${/}insRes.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}Proc1.txt
  ${resource_id_U}=  OperatingSystem.Get File  ${CURDIR}${/}Proc1U.txt
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
  Status Should Be  200  ${response}
  Set Global Variable  ${POLICY_ID_PROC1U}  ${json}