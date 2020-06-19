*** Settings ***
Documentation  Tests for the UMA Flow
Resource  ../../Processing/ADES/ADES.resource
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary


*** Variables ***
${UMA_PATH_PREFIX}=  /wps3
${PATH_TO_RESOURCE}=  pep/ADES
${WELL_KNOWN_PATH}=  http://eoepca-dev.deimos-space.com/.well-known/uma2-configuration

*** Test Cases ***
UMA Get Client from Config File
  ${data}=  OperatingSystem.Get File  ./conf.json
  ${json}=  Evaluate  json.loads('''${data}''')  json
  ${g_client_id}=  Get From Dictionary  ${json}  client_id
  ${g_client_secret}=  Get From Dictionary  ${json}  client_secret
  ${USER}=  Get From Dictionary  ${json}  username
  ${PWD}=  Get From Dictionary  ${json}  password
  Set Global Variable  ${g_client_id} 
  Set Global Variable  ${g_client_secret}
  Set Global Variable  ${USER} 
  Set Global Variable  ${PWD}

UMA getEndpoints
  UMA Get Token Endpoint  ${WELL_KNOWN_PATH}

UMA Ticket Test
  UMA Get Ticket Valid  ${ADES_BASE_URL}  ${RPT_TOKEN}  ${PATH_TO_RESOURCE}

UMA Authenticate test
  UMA Get ID Token Valid  ${ADES_BASE_URL}  ${WELL_KNOWN_PATH}  ${USER}  ${PWD}  ${g_client_id}  ${g_client_secret}

UMA Flow to Retrieve RPT 
  UMA Flow Setup  ${ADES_BASE_URL}  ${RPT_TOKEN}  ${PATH_TO_RESOURCE}  ${WELL_KNOWN_PATH}  ${USER}  ${PWD}  ${g_client_id}  ${g_client_secret}

*** Keywords ***

UMA Flow Setup
  [Arguments]  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  ${tkn}=  UMA Handler of Codes  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  UMA read resource  ${tkn}
  [Return]  ${tkn} 

UMA Get Ticket
  [Arguments]  ${base_url}  ${token}  ${resource}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  authorization=Bearer ${token}
  ${resp}=  Get Request  ades  /${resource}  headers=${headers}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  [Return]  ${resp}  

UMA Get Ticket Valid
  [Arguments]  ${base_url}  ${token}  ${resource}
  ${resp}=  UMA Get Ticket  ${base_url}  ${token}  ${resource}
  Status Should Be  401  ${resp}
  [Return]  ${resp}

UMA Get ID Token
  [Arguments]  ${base_url}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${token_endpoint}
  Create Session  loginService  ${token_endpoint}  verify=False
  ${headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
  ${body}=  Create Dictionary  reponse_type  token id_token  scope  openid  grant_type  password  username  ${user}  password  ${pwd}  client_id  ${client_id}  client_secret  ${client_secret}
  ${key}=  Evaluate  {'redirect_uri': 'https://example.com', 'scope': 'openid', 'grant_type': 'password', 'username' : '${user}', 'password' : '${pwd}', 'client_id' : '${client_id}', 'client_secret': '${client_secret}'}
  ${form}=  Evaluate  {'scope': (None, 'openid'), 'grant_type': (None, 'password'), 'username': (None, '${user}'), 'password': (None, '${pwd}'), 'client_id': (None, '${client_id}'), 'client_secret': (None, '${client_secret}')}
  ${resp}=  Post Request  loginService  /  data=${body}   headers=${headers}
  [Return]  ${resp}  

UMA Call Shell ID Token
  [Arguments]  ${endpoint}  ${client_id}  ${client_secret}
  ${a}=  Run Process  sh  ./id.sh  -t  ${endpoint}  -i  ${client_id}  -p  ${client_secret}
  [Return]  ${a.stdout}

UMA Get ID Token Valid
  [Arguments]  ${base_url}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell ID Token  ${endpoint}  ${client_id}  ${client_secret}
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  [Return]  ${id_token}
  
UMA Get Access Token
  [Arguments]  ${base_url}  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${token_endpoint}
  Create Session  accessService  ${token_endpoint}  verify=False
  ${headers}=  Create Dictionary  content-type  application/x-www-form-urlencoded
  ${data}=  Create Dictionary  claim_token_format  http://openid.net/specs/openid-connect-core-1_0.html#IDToken  claim_token  ${token}  ticket  ${ticket}  grant_type  urn:ietf:params:oauth:grant-type:uma-ticket  client_id  ${client_id}  client_secret  ${client_secret}  scope  openid
  ${resp}=  Post Request  accessService  /  headers=${headers}  data=${data}
  [Return]  ${resp}  

UMA Call Shell Access Token
  [Arguments]  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${token_endpoint}
  ${a}=  Run Process  bash  ./rpt.sh  -S  -a  ${token_endpoint}  -t  ${ticket}  -i  ${client_id}  -p  ${client_secret}  -s  openid  -c  ${token}
  [Return]  ${a.stdout}

UMA Get Access Token Valid
  [Arguments]  ${well_known}  ${ticket}  ${token}  ${client_id}  ${client_secret}  
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell Access Token  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  ${rpt_token}=  UMA Get Access Token From Response  ${resp}
  [Return]  ${rpt_token}

UMA Get Token Endpoint
  [Arguments]  ${well_known} 
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}
  
UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  [Return]  ${ticket}

UMA Get ID Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${id_token}=  Get From Dictionary  ${json}  id_token
  [Return]  ${id_token} 

UMA Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token} 

UMA read resource
  [Arguments]  ${tkn}
  ${contents}=  OperatingSystem.Get File  ../../Processing/ADES/ADES.resource
  @{lines}=  Split to lines  ${contents}
  Create File  ../../Processing/ADES/ADES.resource
  FOR  ${line}  IN  @{lines}
    ${length}=  GetLength  ${line}
    ${match}  ${value}  Run Keyword And Ignore Error  Should Contain  ${line}  RPT_TOKEN
    ${RETURNVALUE}  Set Variable If  '${match}' == 'PASS'  ${True}  ${False}
    Run Keyword if  ${RETURNVALUE} == False and ${length} != 0  Append To File  ../../Processing/ADES/ADES.resource  ${line}\n
    Run Keyword if  ${RETURNVALUE} == True  UMA Write in Resource  ${tkn}
  END
  #Log to console  Updated resource with the RPT Token

UMA Write in Resource
  [Arguments]  ${variable}
  ${i}=  Convert To String  ${\n}\${RPT_TOKEN}= ${space}${variable}
  Append To File  ../../Processing/ADES/ADES.resource  ${i}

UMA Handler of Codes
  [Arguments]  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}  
  ${resp_ticket}=  UMA Get Ticket Valid  ${base_url}  ${token}  ${resource}
  ${ticket}=  UMA Get Ticket From Response  ${resp_ticket}
  #Log to console  The ticket is: 
  #Log to console  ${ticket}
  ${id_token}=  UMA Get ID Token Valid  ${base_url}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  #Log to console  The id_token is:
  #Log to console  ${id_token}
  ${access_token}=  UMA Get Access Token Valid  ${well_known}  ${ticket}  ${id_token}  ${client_id}  ${client_secret}
  #Log to console  The access_token is:
  #Log to console  ${access_token}
  [Return]  ${access_token}