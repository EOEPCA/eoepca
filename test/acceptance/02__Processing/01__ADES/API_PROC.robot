*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Resource  ADES.resource
Library  OperatingSystem

Suite Setup  API_PROC Suite Setup  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}


*** Variables ***
${API_PROC_PATH_PREFIX}=  /wps3
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate

*** Test Cases ***
API_PROC Deploy and Undeploy Application Protection
  ADES Deploy Protection  ${HOST}  ${PORT}

API_PROC Execution Protection
  ADES Execution Protection

API_PROC service is alive
  API_PROC Request Processes Valid  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${RPT_TOKEN}

API_PROC available processes
  API_PROC Processes Are Expected  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  ${INITIAL_PROCESS_NAMES}  ${RPT_TOKEN}

API_PROC deploy process
  API_PROC Deploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json  ${RPT_TOKEN}
  Sleep  5  Waiting for process deploy process to complete asynchronously
  API_PROC Is Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${RPT_TOKEN}

API_PROC execute process
  ${location}=  API_PROC Execute Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_execute.json  ${RPT_TOKEN}
  Sleep  3  Waiting for process execution to start
  ${job_id}=  API_PROC Get Job ID From Location  ${location}
  API_PROC Check Job Status Success  ${ADES_BASE_URL}  ${location}  ${RPT_TOKEN}

API_PROC undeploy Process
  API_PROC Undeploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0_undeploy.json  ${RPT_TOKEN}
  Sleep  3  Waiting for process undeploy process to complete asynchronously
  API_PROC Is Not Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${RPT_TOKEN}


*** Keywords ***
API_PROC Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

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
  Log to Console  ----- ${json} -----
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


API_PROC Request Processes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  authorization=Bearer ${token}
  Log  ${headers}
  ${resp}=  Get Request  ades  ${path_prefix}/processes  headers=${headers}
  Log  ${resp}
  [Return]  ${resp}

API_PROC Request Processes Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes  ${base_url}  ${path_prefix}  ${token}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

API_PROC Deploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesdeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Undeploy Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token} 
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eoepcaadesundeployprocess/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}

API_PROC Is Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Should Contain  ${processes}  ${process_name}

API_PROC Is Not Deployed
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Should Not Contain  ${processes}  ${process_name}

API_PROC Get Process List
  [Arguments]  ${base_url}  ${path_prefix}  ${token}
  ${resp}=  API_PROC Request Processes Valid  ${base_url}  ${path_prefix}  ${token}
  @{processes}=  API_PROC Get Process Names From Response  ${resp}
  [Return]  @{processes}

API_PROC Get Process Names From Response
  [Arguments]  ${resp}
  ${json}=  Set Variable  ${resp.json()}
  ${process_names}=  Create List
  FOR  ${process}  IN  @{json["processes"]}
    Append To List  ${process_names}  ${process["id"]}
  END
  [Return]  ${process_names}

API_PROC Processes Are Expected
  [Arguments]  ${base_url}  ${path_prefix}  ${expected_process_names}  ${token}
  ${processes}=  API_PROC Get Process List  ${base_url}  ${path_prefix}  ${token}
  Lists Should Be Equal  ${processes}  ${expected_process_names}  ignore_order=True

API_PROC Execute Process
  [Arguments]  ${base_url}  ${path_prefix}  ${process_name}  ${filename}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  ${file_data}=  Get Binary File  ${filename}
  ${resp}=  Post Request  ades  ${path_prefix}/processes/eo_metadata_generation_1_0/jobs  headers=${headers}  data=${file_data}
  Status Should Be  201  ${resp}
  [Return]  ${resp.headers["Location"].split("${base_url}")[-1]}

API_PROC Get Job ID From Location
  [Arguments]  ${location}
  ${job_id}=  Evaluate  $location.split("/")[-1]
  [Return]  ${job_id}

API_PROC Check Job Status Success
  [Arguments]  ${base_url}  ${location}  ${token}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  accept=application/json  Prefer=respond-async  Content-Type=application/json  authorization=Bearer ${token}
  FOR  ${index}  IN RANGE  40
    Sleep  30  Loop wait for processing execution completion
    ${resp}=  Get Request  ades  ${location}  headers=${headers}
    Status Should Be  200  ${resp}
    ${status}=  Set Variable  ${resp.json()["status"]}
    Exit For Loop If  "${status}" != "running"
  END
  Should Match  ${resp.json()["status"]}  successful
  Should Match  ${resp.json()["message"]}  Done
  Should Match  ${resp.json()["progress"]}  100
