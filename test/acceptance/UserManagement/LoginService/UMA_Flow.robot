*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Resource  ADES.resource
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary


*** Variables ***
${UMA_PATH_PREFIX}=  /wps3
${PATH_TO_RESOURCE}=  pep/ADES
${WELL_KNOWN_PATH}=  /.well-known
${UMA_CONFIG_PATH}=  /uma2-configuration
${TOKEN_ENDPOINT}=  https://eoepca-dev.deimos-space.com/oxauth/restv1/token
${USER}=  admin
${PWD}=  admin_Abcd1234%23
${CLIENT_ID}=  be7d5fe9-4e60-4a84-a814-507e25687068
${CLIENT_SECRET}=  a1a46378-eabc-4776-b95b-096f1dc215db
${TICKET}=  475f35b7-4f83-4046-87c2-936deca0d71b
${TOKEN}=  eyJraWQiOiI3N2QzODA1MS0xMmE0LTQ1ODYtYjVjMi1kM2EzMTcyOTc4OGNfc2lnX3JzMjU2IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJhdWQiOiJiZTdkNWZlOS00ZTYwLTRhODQtYTgxNC01MDdlMjU2ODcwNjgiLCJzdWIiOiIxZjZjMzIyOS0wOTY4LTQ0YTItYmI1NC1mZjJkMjVlYTBlNTIiLCJpc3MiOiJodHRwczovL2VvZXBjYS1kZXYuZGVpbW9zLXNwYWNlLmNvbSIsImV4cCI6MTU5MjIyNjE4NiwiaWF0IjoxNTkyMjIyNTg2LCJveE9wZW5JRENvbm5lY3RWZXJzaW9uIjoib3BlbmlkY29ubmVjdC0xLjAifQ.XDLrRhYoqABEljxUTvyxr2wjtJhRHyrFILKRFYidKesMONr_tH9UO3bu1R3Izifnu6HMETrslbksv-J2mE2idlj8k_PXk0mqrMrLWo9H7f0DXSizonau3L3MmjQboS_LxC7RmeRQCVunt8sgTE_3-SrS4HuudCE3vMQPe-iIHBvoz111T1gInA-hycy63AOjZCLj27dFT_QGIK5BfU4sYWn6FhOZysTPDLqVqbjGb3Thc9evapD7XVeJ4TMHiIN9CLyhmX0AhjXWAW2gZMkWPn6W4X1aGZ5K0xxz3k69906pU31n2itY4XBJ6ONcwM2JUvEvs0b1FynKrp8_dtkPAQ

*** Test Cases ***
UMA Ticket Test
  UMA Get Ticket Valid  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${RPT_TOKEN}  ${PATH_TO_RESOURCE}

UMA Authenticate test
  UMA Get ID Token Valid  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${WELL_KNOWN_PATH}  ${UMA_CONFIG_PATH}  ${USER}  ${PWD}  ${CLIENT_ID}  ${CLIENT_SECRET}  ${TOKEN_ENDPOINT}

UMA Retrieve RPT_TOKEN
  UMA Get Access Token Valid  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${TICKET}  ${TOKEN}  ${CLIENT_ID}  ${CLIENT_SECRET}  ${TOKEN_ENDPOINT}

Suite Setup  UMA Suite Setup  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${RPT_TOKEN}  ${PATH_TO_RESOURCE}  ${WELL_KNOWN_PATH}  ${UMA_CONFIG_PATH}  ${USER}  ${PWD}  ${CLIENT_ID}  ${CLIENT_SECRET}




*** Keywords ***

UMA Suite Setup
  [Arguments]  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${processes}=  UMA Handler of Codes  ${base_url}  ${path_prefix}  ${token}  ${resource}
  Set Suite Variable  @{INITIAL_PROCESS_NAMES}  @{processes}

UMA Get Ticket
  [Arguments]  ${base_url}  ${path_prefix}  ${token}  ${resource}
  Create Session  ades  ${base_url}  verify=True
  ${headers}=  Create Dictionary  authorization=Bearer ${token}
  ${resp}=  Get Request  ades  ${base_url}/${resource}  headers=${headers}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  Log to console  ${ticket}
  Log to console  ${resp.status_code}
  [Return]  ${resp}  

UMA Get Ticket Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${resp}=  UMA Get Ticket  ${base_url}  ${path_prefix}  ${token}  ${resource}
  Status Should Be  401  ${resp}
  [Return]  ${resp}


UMA Get ID Token
  [Arguments]  ${base_url}  ${path_prefix}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${token_endpoint}
  Create Session  loginService  ${token_endpoint}  verify=False
  ${headers}=  Create Dictionary  Content-Type=application/x-www-form-urlencoded
  ${body}=  Create Dictionary  reponse_type  token id_token  scope  openid  grant_type  password  username  ${user}  password  ${pwd}  client_id  ${client_id}  client_secret  ${client_secret}
  ${key}=  Evaluate  {'redirect_uri': 'https://example.com', 'scope': 'openid', 'grant_type': 'password', 'username' : '${user}', 'password' : '${pwd}', 'client_id' : '${client_id}', 'client_secret': '${client_secret}'}
  ${form}=  Evaluate  {'scope': (None, 'openid'), 'grant_type': (None, 'password'), 'username': (None, '${user}'), 'password': (None, '${pwd}'), 'client_id': (None, '${client_id}'), 'client_secret': (None, '${client_secret}')}
  ${resp}=  Post Request  loginService  /  data=${body}   headers=${headers}
  Log to console  ${resp.iter_lines}
  Log to console  ${resp.iter_content}
  Log to console  ${resp.url}
  
  [Return]  ${resp}  


UMA Call Shell ID Token
  ${a}=  Run Process  sh  ./sett.sh
  [Return]  ${a.stdout}

UMA Get ID Token Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${endpoint}
  ${resp}=  UMA Call Shell ID Token
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  Log to console  ${id_token}
  [Return]  ${id_token}
  

UMA Get Access Token
  [Arguments]  ${base_url}  ${path_prefix}  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${token_endpoint}
  Create Session  accessService  ${token_endpoint}  verify=False
  ${headers}=  Create Dictionary  content-type  application/x-www-form-urlencoded
  ${data}=  Create Dictionary  claim_token_format  http://openid.net/specs/openid-connect-core-1_0.html#IDToken  claim_token  ${token}  ticket  ${ticket}  grant_type  urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Auma-ticket  client_id  ${client_id}  client_secret  ${client_secret}  scope  openid
  ${resp}=  Post Request  accessService  ${token_endpoint} headers=${headers} data=${data}
  Log to console  ${resp.iter_lines}
  Log to console  ${resp.iter_content}
  Log to console  ${resp.text}
  [Return]  ${resp}  

UMA Get Access Token Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  ${resp}=  UMA Get Access Token  ${base_url}  ${path_prefix}  ${ticket}  ${token}  ${client_id}  ${client_secret}  ${endpoint}
  Log to console  ${resp}
  Status Should Be  200  ${resp}
  [Return]  ${resp}

UMA Get Token Endpoint
  [Arguments]  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}
  Create Session  ades  ${base_url}  verify=True
  ${url}=  Fetch From Left  ${base_url}  :32125
  ${resp}=  Get Request  ades  ${url}${well_known}${uma_path}
  ${endpoint}=  Fetch From Right  ${resp}  token_endpoint=
  [Return]  ${resp}
  
UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  Log to console  ${ticket}
  [Return]  ${ticket}

UMA Get ID Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${id_token}=  Get From Dictionary  ${json}  id_token
  [Return]  ${id_token} 


UMA Handler of Codes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${resp_ticket}=  UMA Get Ticket Valid  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${ticket}=  UMA Get Ticket From Response  ${resp_ticket}
  ${id_token}= UMA Get ID Token Valid  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${endpoint}
  [Return]  @{resp}