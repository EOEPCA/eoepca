*** Settings ***
Documentation  Tests for the UMA Flow
Library  Collections
Library  RequestsLibrary
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary
Library  ../ScimClient.py  ${UM_BASE_URL}/

*** Keywords ***

UMA Flow Setup
  [Arguments]  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}
  ${resp}=  Scim Client Get Details
  ${g_client_id}=  Get From Dictionary  ${resp}  client_id
  ${g_client_secret}=  Get From Dictionary  ${resp}  client_secret
  Set Global Variable  ${C_ID_UMA}  ${g_client_id}
  Set Global Variable  ${C_SECRET_UMA}  ${g_client_secret}
  ${tkn}=  UMA Handler of Codes  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}  ${g_client_id}  ${g_client_secret}
  Set Global Variable  ${RPT_TOKEN}  ${tkn}
  [Return]  ${tkn} 

UMA Get Ticket PEP
  [Arguments]  ${base_url}  ${token}  ${resource}
  Create Session  pep  ${base_url}  verify=False
  ${headers}=  Create Dictionary  authorization=Bearer ${ID_TOKEN}
  ${resp}=  Get Request  pep  ${resource}  headers=${headers}
  [Return]  ${resp}

UMA Get Ticket Valid PEP
  [Arguments]  ${base_url}  ${token}  ${resource}
  ${resp}=  UMA Get Ticket PEP  ${ADES_BASE_URL}  ${ID_TOKEN}  ${resource}
  [Return]  ${resp}

UMA Call Shell ID Token
  [Arguments]  ${endpoint}  ${client_id}  ${client_secret}  ${user}  ${pwd}
  ${a}=  Run Process  sh  ${CURDIR}${/}id.sh  -t  ${endpoint}  -i  ${client_id}  -p  ${client_secret}  -u  ${user}  -w  ${pwd}
  ${n}=  OperatingSystem.Get File  ${CURDIR}${/}1.txt
  #OperatingSystem.Remove File  ${CURDIR}${/}1.txt
  [Return]  ${n}

UMA Get ID Token Valid PEP
  [Arguments]  ${base_url}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell ID Token  ${endpoint}  ${client_id}  ${client_secret}  ${user}  ${pwd}
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  Set Global Variable  ${ID_TOKEN}  ${id_token}
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
  ${a}=  Run Process  bash  ${CURDIR}${/}rpt.sh  -S  -a  ${token_endpoint}  -t  ${ticket}  -i  ${client_id}  -p  ${client_secret}  -s  openid  -c  ${token}
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

UMA Handler of Codes
  [Arguments]  ${base_url}  ${token}  ${resource}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  ${id_token}=  UMA Get ID Token Valid PEP  ${base_url}  ${well_known}  ${user}  ${pwd}  ${client_id}  ${client_secret}
  ${resp_ticket}=  UMA Get Ticket Valid PEP  ${base_url}  ${token}  ${resource}
  ${ticket}=  builtIn.Run Keyword If  "${resp_ticket.status_code}"=="401"  UMA Get Ticket From Response  ${resp_ticket}
  ${access_token}=  builtIn.Run Keyword If  "${resp_ticket.status_code}"=="401"  UMA Get Access Token Valid  ${well_known}  ${ticket}  ${id_token}  ${client_id}  ${client_secret}
  [Return]  ${access_token}


Cleanup
  OperatingSystem.Remove File  ${CURDIR}${/}1.txt
  OperatingSystem.Remove File  ${CURDIR}${/}res_id.txt
