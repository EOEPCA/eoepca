*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Resource  ADES.resource
Library  OperatingSystem
Library  String


*** Variables ***
${UMA_PATH_PREFIX}=  /wps3
${PATH_TO_RESOURCE}=  pep/ADES
${WELL_KNOWN_PATH}=  /.well-known
${UMA_CONFIG_PATH}=  /uma2-configuration
${TOKEN_ENDPOINT}=  https://eoepca-dev.deimos-space.com/oxauth/restv1/token
${USER}=  admin
${PWD}=  admin_Abcd1234#
${CLIENT_ID}=  be7d5fe9-4e60-4a84-a814-507e25687068
${CLIENT_SECRET}=  a1a46378-eabc-4776-b95b-096f1dc215db

*** Test Cases ***
UMA Ticket Test
  UMA Get Ticket Valid  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${RPT_TOKEN}  ${PATH_TO_RESOURCE}

UMA Authenticate test
  UMA Get ID Token Valid  ${ADES_BASE_URL}  ${UMA_PATH_PREFIX}  ${WELL_KNOWN_PATH}  ${UMA_CONFIG_PATH}  ${USER}  ${PWD}  ${CLIENT_ID}  ${CLIENT_SECRET}  ${TOKEN_ENDPOINT}


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
  Create Session  ades  ${token_endpoint}  verify=False
  ${data}=  Create Dictionary  scope=openid  grant_type=password  username=${user}  password=${pwd}  client_id=${client_id}  client_secret=${client_secret}
  Log to console  ${data['client_id']}
  ${resp}=  Post Request  ades  ${token_endpoint} data=${data}
  


  Log to console  ${resp.json}

  Log to console  ${resp.status_code}
  [Return]  ${resp}  


UMA Get ID Token Valid
  [Arguments]  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${endpoint}
  ${resp}=  UMA Get ID Token  ${base_url}  ${path_prefix}  ${user}  ${pwd}  ${client_id}  ${client_secret}  ${endpoint}
  Log to console  ${resp}
  Status Should Be  401  ${resp}
  [Return]  ${resp}
  

UMA Get Token Endpoint
  [Arguments]  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}
  Create Session  ades  ${base_url}  verify=True
  ${url}=  Fetch From Left  ${base_url}  :32125
  
  ${resp}=  Get Request  ades  ${url}${well_known}${uma_path}

  Log to console  ${resp.status_code}
  Log to console  ${url}${well_known}${uma_path}
  ${endpoint}=  Fetch From Right  ${resp}  token_endpoint=
  Log to console  ${ticket}
  Log to console  ${resp.status_code}
  [Return]  ${resp}

UMA Handler of Codes
  [Arguments]  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${resp_ticket}=  UMA Get Ticket Valid  ${base_url}  ${path_prefix}  ${token}  ${resource}
  ${ticket}=  UMA Get Ticket From Response  ${resp_ticket}
  ${token_endpoint}=  UMA Get Token Endpoint  ${base_url}  ${path_prefix}  ${well_known}  ${uma_path}
  ${resp_id_token}= UMA Get ID Token
  [Return]  @{resp}
  
UMA Get Ticket From Response
  [Arguments]  ${resp}
  ${location_header}=  Get From Dictionary  ${resp.headers}  WWW-Authenticate
  ${ticket}=  Fetch From Right  ${location_header}  ticket=
  Log to console  ${ticket}
  [Return]  ${ticket}