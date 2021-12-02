*** Settings ***
Documentation  Tests for the PDP
Library  Collections
Library  RequestsLibrary
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

*** Variables ***
${PDP_PATH_TO_VALIDATE}=  /pdp/policy/validate

*** Test Cases ***

PDP Access Permitted eric -> /ericspace
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  get  ${ericspace_id}

PDP Access Denied bob -> /ericspace
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Denied  bob  get  ${ericspace_id}

PDP Access Permitted bob -> /bobspace
  ${bob_id_token}=  Get Id Token  bob  defaultPWD
  ${bobspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /bobspace  ${bob_id_token}
  PDP Validate Resource Access Permit  bob  get  ${bobspace_id}

PDP Access Permitted GET
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  get  ${ericspace_id}

PDP Access Permitted POST
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  post  ${ericspace_id}

PDP Access Permitted PUT
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  put  ${ericspace_id}

PDP Access Permitted DELETE
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  delete  ${ericspace_id}

PDP Access Permitted HEAD
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  eric  head  ${ericspace_id}

PDP Policy Validate Bad Action
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Denied  eric  bad  ${ericspace_id}

PDP Policy Validate Bad Resource
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /bad  ${eric_id_token}
  PDP Validate Resource Access Denied  eric  get  ${ericspace_id}
 
*** Keywords ***

PDP Validate Resource Access
  [Arguments]  ${user_name}  ${action}  ${resource_id}  ${expected_status}
  ${headers}=  Create Dictionary  Content-Type  application/json
  ${data} =  Evaluate  {"Request":{"AccessSubject":[{"Attribute":[{"AttributeId":"user_name","Value": "${user_name}","DataType":"string","IncludeInResult":True}]}],"Action":[{"Attribute":[{"AttributeId":"action-id","Value":"${action}"}]}],"Resource":[{"Attribute":[{"AttributeId":"resource-id","Value":"${resource_id}","DataType":"string","IncludeInResult":True}]}]}}  json
  Create Session  pdp  ${UM_BASE_URL}  verify=False
  ${resp}=  Get On Session  pdp  ${PDP_PATH_TO_VALIDATE}  headers=${headers}  json=${data}  expected_status=${expected_status}
  ${json}=  Evaluate  json.loads('''${resp.text}''')  json
  ${response}=  Get From Dictionary  ${json}  Response
  ${decision}=  Get From List  ${response}  0
  ${value_decision}=  Get From Dictionary  ${decision}  Decision
  [Return]  ${value_decision}

PDP Validate Resource Access Permit
  [Arguments]  ${user_name}  ${action}  ${resource_id}
  ${decision}=  PDP Validate Resource Access  ${user_name}  ${action}  ${resource_id}  200
  Should Be Equal As Strings  ${decision}  Permit

PDP Validate Resource Access Denied
  [Arguments]  ${user_name}  ${action}  ${resource_id}
  ${decision}=  PDP Validate Resource Access  ${user_name}  ${action}  ${resource_id}  401
  Should Be Equal As Strings  ${decision}  Deny
