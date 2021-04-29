*** Settings ***
Documentation  Tests for the UMA Flow
Library  Collections
Library  RequestsLibrary
Library  OperatingSystem
Library  String
Library  Process
Library  SSHLibrary

*** Variables ***
${HOST}=  ${UM_BASE_URL}
${PORT}=  443
${PDP_PATH_TO_VALIDATE}=  pdp/policy/validate
${WELL_KNOWN_PATH}=  ${UM_BASE_URL}/.well-known/openid-configuration
${SCOPES}=  openid,permission,uma_protection 
${REQ}=  grant_type=password&client_id=${C_ID_UMA}&client_secret=${C_SECRET_UMA}&username=admin&password=admin_Abcd1234#&scope=${SCOPES}&uri=

*** Test Cases ***

PDP Permit Policy
  PDP Get Permit Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Permit Policy Invalid ResourceID
  PDP Get Permit With Invalid Resource Policy  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}

PDP Deny Policy Valid ResourceID Invalid Uid
  #PDP Get Deny Policy Uid  ${HOST}  ${PORT}  ${PDP_PATH_TO_VALIDATE}
  Cleanup
 
*** Keywords ***

PDP Get Ownership
  ${a}=  Run Process  python3  ${CURDIR}${/}getOwnership.py  ${ID_TOKEN}
  ${owId}=  OperatingSystem.Get File  ${CURDIR}${/}ownership_id.txt
  Set Global Variable  ${OW_ID}  ${owId}

PDP Get Other Token
  [Arguments]  ${well_known}
  ${ep}=  PDP Get TokenEndpoint  ${well_known}
  ${a}=  Run Process  sh  ${CURDIR}${/}tkn.sh  -t  ${ep}  -i  ${C_ID_UMA}  -s  ${C_SECRET_UMA}  -u  ${USER_A_NAME}  -p  ${USER_A_PASSWORD}  -f  ${CURDIR}${/}2.txt
  ${a}=  Run Process  sh  ${CURDIR}${/}tkn.sh  -t  ${ep}  -i  ${C_ID_UMA}  -s  ${C_SECRET_UMA}  -u  ${USER_B_NAME}  -p  ${USER_B_PASSWORD}  -f  ${CURDIR}${/}3.txt
  ${U1}=  OperatingSystem.Get File  ${CURDIR}${/}2.txt
  ${U1}=  PDP Get Access Token From Response  ${U1}
  Set Global Variable  ${UA_TK}  ${U1}
  ${U2}=  OperatingSystem.Get File  ${CURDIR}${/}3.txt
  ${U2}=  PDP Get Access Token From Response  ${U2}
  Set Global Variable  ${UB_TK}  ${U2}

PDP Get Access Token From Response
  [Arguments]  ${resp}
  ${json}=  Evaluate  json.loads('''${resp}''')  json
  ${access_token}=  Get From Dictionary  ${json}  access_token
  [Return]  ${access_token}

PDP Get TokenEndpoint
  [Arguments]  ${well_known}
  ${headers}=  Create Dictionary  Content-Type  application/json
  Create Session  ep  ${well_known}  verify=False
  ${resp}=  Get Request  ep  /
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${tk_endpoint}=  Get From Dictionary  ${json}  token_endpoint
  [Return]  ${tk_endpoint}

#Validation
PDP Get Permit Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate}
  PDP Get Ownership
  ${RES_ID_FOUND}=  OperatingSystem.Get File  ${CURDIR}${/}..${/}01__LoginService${/}res_id.txt
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"id","Value": "${OW_ID}","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"${RES_ID_FOUND}","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

PDP Get Permit With Invalid Resource Policy
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate}
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"id","Value": "admin","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"999","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Permit

PDP Get Deny Policy Uid
  [Arguments]  ${host}  ${port}  ${pdp_path_to_validate}
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${RES_ID_FOUND}=  OperatingSystem.Get File  ${CURDIR}${/}..${/}01__LoginService${/}res_id.txt
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"id","Value": "999","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"view"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"${RES_ID_FOUND}","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${host}:${port}  verify=False
  ${resp}=  Get Request  pdp  /${pdp_path_to_validate}  headers=${headers}  json=${data}
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  Should Be Equal As Strings  ${value_decision}  Deny

Cleanup
  OperatingSystem.Remove File  ${CURDIR}${/}2.txt
  OperatingSystem.Remove File  ${CURDIR}${/}3.txt
  OperatingSystem.Remove File  ${CURDIR}${/}ownership_id.txt