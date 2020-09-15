*** Settings ***
Documentation  Tests for the ADES WPS endpoint
Resource  ADES.resource
Library  XML
Library  Process
Library  OperatingSystem
Library  String
Library  ../../01__UserManagement/ScimClient.py  ${UM_BASE_URL}/


*** Variables ***
${WPS_PATH_PREFIX}=  /zoo
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate   

*** Test Cases ***
ADES Protection as Service
  #User C attempts to perform a GetCapabilities. Access granted. NO TICKET
  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${PATH_PREFIX}
  #UserD gets id_token
  UMA Get ID Token Valid
  #User D protects the root path of ADES (“/”) with an “Authenticated” scope
  PEP Register ADES
  #UserC attempts to perform a GetCapabilities.
  ${ticket}=  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${PATH_PREFIX}
  #Check ticket against uma and denied
  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${ID_TOKEN}  ${C_ID_UMA}  ${C_SECRET_UMA}
  #UserA and UserB attempsts to perform a GetCapabilities
  ${ticket}=  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${PATH_PREFIX}
  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UA_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}
  ${ticket}=  WPS Get Capabilities Without Token  ${ADES_BASE_URL}  ${PATH_PREFIX}
  UMA Get Access Token Valid  ${WELL_KNOWN_PATH}  ${ticket}  ${UB_TK}  ${C_ID_UMA}  ${C_SECRET_UMA}

ADES Application Deployment Protection
#   User A deploys Proc1
#   User A registers the resulting application Proc1 as a protected resource
#   User A assigns an ownership policy to Proc1
#   User A registers the undeploy operation for Proc1 as a protected resource
#   User A assigns an ownership policy to Proc1
#   User B attempts to undeploy Proc1. Unauthorized.
ADES Application Execution Protection
#   User A attempts to execute Proc1. Success → Generation of a Job1 object.
#   User A registers the Location of the Job1 status as protected resource with ownership policy
#   User B attempts to execute Proc1. Unauthorized.
#   User B attempts to retrieve status of Job1. Unauthorized.
#   User A attempts to retrieve status of Job1. OK.
Policy Ownership and Policy Updates
#   User B attempts to modify Proc1 access policies. Unauthorized. 
#   User A modifies access policy of Job1 Status to Access List including User B.
#   User B attempts to retrieve the status of Job1. OK.
#   User A modifies access policy of Proc1 to Access List including User B.
#   User B attempts to execute Proc1. OK.


*** Keywords ***

UMA Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token}

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
  
PEP Register ADES 
  ${a}=  Run Process  python3  ${CURDIR}${/}insertADES.py
  ${resource_id}=  OperatingSystem.Get File  ${CURDIR}${/}ADES.txt
  OperatingSystem.Remove File  ${CURDIR}${/}ADES.txt
  Set Global Variable  ${RES_ID_ADES}  ${resource_id}

UMA Call Shell ID Token
  [Arguments]  ${endpoint}  ${client_id}  ${client_secret}
  ${a}=  Run Process  sh  ${CURDIR}${/}id.sh  -t  ${endpoint}  -i  ${client_id}  -p  ${client_secret}
  ${n}=  OperatingSystem.Get File  ${CURDIR}${/}1.txt
  #OperatingSystem.Remove File  ${CURDIR}${/}1.txt
  [Return]  ${n}

UMA Get ID Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${id_token}=  Get From Dictionary  ${json}  id_token
  [Return]  ${id_token} 

UMA Get ID Token Valid
  [Arguments]  ${well_known}  ${client_id}  ${client_secret}
  ${endpoint}=  UMA Get Token Endpoint  ${well_known}
  ${resp}=  UMA Call Shell ID Token  ${endpoint}  ${client_id}  ${client_secret}
  ${id_token}=  UMA Get ID Token From Response  ${resp}
  Set Global Variable  ${ID_TOKEN}  ${id_token}
  [Return]  ${id_token}

WPS Get Capabilities Without Token
  [Arguments]  ${base_url}  ${path_prefix}
  Create Session  ades  ${base_url}  verify=True
  ${resp}=  Get Request  ades  ${path_prefix}/?service=WPS&version=1.0.0&request=GetCapabilities
  [Return]  ${resp}










