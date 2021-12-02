*** Settings ***
Documentation  Tests for the UMA Flow
Library  RequestsLibrary
Library  Collections
Library  String
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown

*** Variables ***
${UMA2_CONFIG_PATH}=  /.well-known/uma2-configuration

*** Test Cases ***

UMA Get Endpoints
  UMA Get Token Endpoint  ${UM_BASE_URL}

UMA Ticket Test
  UMA Get Ticket  ${DUMMY_PEP_AUTH_HOSTNAME}  ${RPT_TOKEN}  "/test"  "GET"

UMA RPT Test
  ${resp}  ${as_uri}  ${ticket}=  UMA Get Ticket  ${DUMMY_PEP_AUTH_HOSTNAME}  ${RPT_TOKEN}  "/test"  "GET"
  ${g_client_id}  ${g_client_secret}=  Get Client Credentials
  Log  Client ID is ${g_client_id}
  Log  Client Secret is ${g_client_secret}
  ${id_token}=  Get ID Token  ${USER_A_NAME}  ${USER_A_PASSWORD}
  Should Not Be Empty  ${id_token}
  ${rpt}=  UMA Get RPT From Ticket  ${id_token}  ${as_uri}  ${ticket}  ${g_client_id}  ${g_client_secret}
  Should Not Be Empty  ${rpt}

*** Keywords ***

Suite Setup
  Log  Suite Setup  DEBUG

Suite Teardown
  Client Save State

UMA Get Ticket
  [Arguments]  ${pep_hostname}  ${token}  ${resource_uri}  ${request_method}
  Create Session  pep  https://${pep_hostname}  verify=False
  ${headers}=  Create Dictionary  X-Request-Uri=${resource_uri}  X-Request-Method=${request_method}  Authorization=Bearer ${token}
  ${resp}=  GET On Session  pep  /authorize  headers=${headers}  expected_status=any
  ${as_uri}  ${ticket}=  UMA Get Ticket From Response  ${resp}
  [Return]  ${resp}  ${as_uri}  ${ticket}

UMA Get Token Endpoint
  [Arguments]  ${as_uri}
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${as_uri}/${UMA2_CONFIG_PATH}  verify=False
  ${resp}=  Get On Session  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}
  
UMA Get Ticket From Response
  [Arguments]  ${resp}
  Status Should Be  401  ${resp}
  @{www_authenticate}=  Split String  ${resp.headers["Www-Authenticate"]}  ,
  Should Not Be Empty  ${www_authenticate}
  FOR  ${item}  IN  @{www_authenticate}
    @{item}=  Split String  ${item}  =
    Length Should Be  ${item}  2
    IF  "${item[0]}" == "as_uri"
      ${as_uri}=  Set Variable  ${item[1]}
    END
    IF  "${item[0]}" == "ticket"
      ${ticket}=  Set Variable  ${item[1]}
    END
  END
  Should Not Be Empty  ${as_uri}
  Should Not Be Empty  ${ticket}
  [Return]  ${as_uri}  ${ticket}

UMA Get RPT From Ticket
  [Arguments]  ${id_token}  ${as_uri}  ${ticket}  ${client_id}  ${client_secret}
  ${token_endpoint}=  UMA Get Token Endpoint  ${as_uri}
  Should Not Be Empty  ${token_endpoint}
  Create Session  session  ${token_endpoint}  verify=False
  ${headers}=  Create Dictionary  content-type  application/x-www-form-urlencoded  cache-control  no-cache
  ${data}=  Create Dictionary  claim_token_format  http://openid.net/specs/openid-connect-core-1_0.html#IDToken  claim_token  ${id_token}  ticket  ${ticket}  grant_type  urn:ietf:params:oauth:grant-type:uma-ticket  client_id  ${client_id}  client_secret  ${client_secret}  scope  openid
  ${resp}=  Post On Session  session  ${None}  headers=${headers}  data=${data}
  Status Should Be  200  ${resp}
  ${rpt}=  Get From Dictionary  ${resp.json()}  access_token
  Should Not Be Empty  ${rpt}
  [Return]  ${rpt}
