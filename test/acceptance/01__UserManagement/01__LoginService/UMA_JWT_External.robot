*** Settings ***
Documentation  Tests for the External JWT Protected Access
Library  Collections
Library  RequestsLibrary
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary
Library  ../ScimClient.py  ${UM_BASE_URL}/

*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${API_PROC_PATH_PREFIX}=  /wps3
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/uma2-configuration

*** Test Cases ***

Protected Access with External JWT
  UMA Get External ID Token
  PEP Register Proc1
  PDP Register Proc1  ${UM_BASE_URL}
  UMA Get Ticket
  UMA Flow Get Client
  ${token_endpoint}=  UMA Get Token Endpoint
  ${resp}=  Run Process  bash  ${CURDIR}${/}rpt.sh  -S  -a  ${token_endpoint}  -t  ${TICKET}  -i  ${CLIENT_ID}  -p  ${CLIENT_SECRET}  -s  openid  -c  ${ID_TOKEN}
  Log to console  ${resp.stdout}
  ${json}=  Evaluate  json.loads('''${resp.stdout}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  Cleanup

  
*** Keywords ***
UMA Get External ID Token
  ${a}=  Run Process  sh  ${CURDIR}${/}id_external.sh
  ${resp}=  OperatingSystem.Get File  ${CURDIR}${/}external_id.txt
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${id_token}=  Get From Dictionary  ${json}  id_token
  Set Global Variable  ${ID_TOKEN}  ${id_token}

PEP Register Proc1
  ${a}=  Run Process  python3  ${CURDIR}${/}insProtectedADES.py  ${UM_BASE_URL}
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}res_id_ext.txt
  Set Global Variable  ${RES_ID}  ${resource_id}

PDP Register Proc1
  [Arguments]  ${host}
  Create Session  pdp  ${host}:443  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${data} =  Evaluate  {"name":"NewPolicy1","description":"Description for this new policy","config":{"resource_id":"${RES_ID}", "action": "view", "rules":[{"OR":[{"EQUAL":{"issuer":"https://um.nextgeoss.eu"}},{"EQUAL":{"issuer":"https://um.nextgeoss.eu"}}]}]}}
  ${response}=  Post Request  pdp  /pdp/policy/  headers=${headers}  json=${data}
  #Get the policy_id from the response
  ${json}=  Get Substring  ${response.text}  20  45
  Set Global Variable  ${POLICY_ID}  ${json}
  Status Should Be  200  ${response}

UMA Get Token Endpoint
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${WELL_KNOWN_PATH}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  [Return]  ${ticket}

UMA Get Ticket
  Create Session  pep  ${UM_BASE_URL}:443  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${data}=  Evaluate  { "resource_scopes":[ "protected_access"], "icon_uri":"/testexternal", "name":"TestExternal" }
  ${resp}=  Get Request  pep  /secure/testexternal  headers=${headers}  data=${data}
  ${ticket_resp}=  builtIn.Run Keyword If  "${resp.status_code}"=="401"  UMA Get Ticket From Response  ${resp}
  Set Global Variable  ${TICKET}  ${ticket_resp}

UMA Flow Get Client
  ${resp}=  Scim Client Get Details
  ${g_client_id}=  Get From Dictionary  ${resp}  client_id
  ${g_client_secret}=  Get From Dictionary  ${resp}  client_secret
  Set Global Variable  ${CLIENT_ID}  ${g_client_id}
  Set Global Variable  ${CLIENT_SECRET}  ${g_client_secret}

Cleanup
  OperatingSystem.Remove File  ${CURDIR}${/}external_id.txt
  OperatingSystem.Remove File  ${CURDIR}${/}res_id_ext.txt