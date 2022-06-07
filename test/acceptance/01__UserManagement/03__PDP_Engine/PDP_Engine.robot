*** Settings ***
Documentation  Tests for the PDP
Library  Collections
Library  RequestsLibrary
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

*** Variables ***
${PDP_PATH_TO_VALIDATE}=  /pdp/policy/validate
${PDP_BASE_URL}=  ${UM_BASE_URL}/pdp

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

User bob Unauthorized Policy Change
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${bob_id_token}=  Get Id Token  bob  defaultPWD
  ${ow}=  Get Ownership Id  ${eric_id_token}
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  ${data}=  Evaluate  {'name':'UPDATE DENY','description':'modified','config':{'resource_id':'${ericspace_id}','action':'get','rules':[{'OR':[{'EQUAL':{'id':'${ow}'}},{'EQUAL':{'id':'${ow}'}}]}]},'scopes':['protected_get']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${ericspace_id}  ${bob_id_token}
  ${validator}=  Convert To String  ${resp}
  Should Be Equal  ${validator}  401

User eric Authorized Policy Change
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${bob_id_token}=  Get Id Token  bob  defaultPWD
  ${owa}=  Get Ownership Id  ${eric_id_token}
  ${owb}=  Get Ownership Id  ${bob_id_token}
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  ${data}=  Evaluate  {'name':'Modified Ownership Policy of ${ericspace_id} with action get','description':'modified','config':{'resource_id':'${ericspace_id}','action':'get','rules':[{'OR':[{'EQUAL':{'id':'${owa}'}},{'EQUAL':{'id':'${owb}'}}]}]},'scopes':['protected_get']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${ericspace_id}  ${eric_id_token}
  ${validator}=  Convert To String  ${resp}
  Should Be Equal  ${validator}  200

PDP Access Permitted bob -> /ericspace
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  PDP Validate Resource Access Permit  bob  get  ${ericspace_id}

User eric Authorized Policy Change Revert
  ${eric_id_token}=  Get Id Token  eric  defaultPWD
  ${bob_id_token}=  Get Id Token  bob  defaultPWD
  ${owa}=  Get Ownership Id  ${eric_id_token}
  ${owb}=  Get Ownership Id  ${bob_id_token}
  ${ericspace_id}=  Get Resource By URI  ${DUMMY_SERVICE_RESOURCES_API_URL}  /ericspace  ${eric_id_token}
  ${data}=  Evaluate  {'name':'Default Ownership Policy of ${ericspace_id} with action get','description':'This is the default ownership policy for created resources through PEP','config':{'resource_id':'${ericspace_id}','action':'get','rules':[{'AND':[{'EQUAL':{'id':'${owa}'}}]}]},'scopes':['protected_get']}
  ${resp}  ${text}=  Update Policy  ${PDP_BASE_URL}  ${data}  ${ericspace_id}  ${eric_id_token}
  ${validator}=  Convert To String  ${resp}
  Should Be Equal  ${validator}  200

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
