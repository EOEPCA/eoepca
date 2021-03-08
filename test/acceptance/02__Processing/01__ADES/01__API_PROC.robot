*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Library  RequestsLibrary
Library  Collections
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${USERNAME}=  adestest
${PASSWORD}=  defaultPWD
${ADES_WORKSPACE}=  ${USERNAME}
${PROCESS_NAME}=  s-expression-0_0_2
${API_PROC_PATH_PREFIX}=  /${ADES_WORKSPACE}/wps3
${API_PROC_SERVICE_URL}=  ${ADES_BASE_URL}${API_PROC_PATH_PREFIX}
${ID_TOKEN}=
${ACCESS_TOKEN}=


*** Test Cases ***
Initial Process List
  Record Initial Process List

Deploy Application
  Deploy Application  ${CURDIR}${/}data/app-deploy-body.json
  Sleep  5  Waiting for process deploy process to complete asynchronously
  Process Is Deployed  ${PROCESS_NAME}

Get Application Details
  Get Application Details  ${PROCESS_NAME}

Execute Application
  Execute Application Success  ${PROCESS_NAME}  ${CURDIR}${/}data/app-execute-body.json

Undeploy Application
  Undeploy Application  ${PROCESS_NAME}
  Sleep  5  Waiting for process undeploy process to complete asynchronously
  Process Is Not Deployed  ${PROCESS_NAME}


*** Keywords ***
Suite Setup
  Init ID Token  ${USERNAME}  ${PASSWORD}

Suite Teardown
  Client Save State

Init ID Token
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN}  ${id_token}

Record Initial Process List
  ${resp}=  List Processes
  @{processes}=  Get Process Names From Response  ${resp}
  Should Be True  $processes is not None
  Set Suite Variable  ${INITIAL_PROCESS_LIST}  ${processes}

List Processes
  ${resp}  ${access_token} =  Proc List Processes  ${API_PROC_SERVICE_URL}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}

Get Process Names From Response
  [Arguments]  ${resp}
  @{json}=  Set Variable  ${resp.json()}
  ${process_names}=  Create List
  FOR  ${process}  IN  @{json}
    Append To List  ${process_names}  ${process["id"]}
  END
  [Return]  ${process_names}

Get Application Details
  [Arguments]  ${app_name}
  ${resp}  ${access_token} =  Proc App Details  ${API_PROC_SERVICE_URL}  ${app_name}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Deploy Application
  [Arguments]  ${app_filename}
  ${resp}  ${access_token} =  Proc Deploy App  ${API_PROC_SERVICE_URL}  ${app_filename}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  201  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Process Is Deployed
  [Arguments]  ${app_name}
  ${resp}=  List Processes
  @{processes}=  Get Process Names From Response  ${resp}
  Should Be True  $processes is not None
  Should Contain  ${processes}  ${app_name}

Undeploy Application
  [Arguments]  ${app_name}
  ${resp}  ${access_token} =  Proc Undeploy App  ${API_PROC_SERVICE_URL}  ${app_name}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  200  ${resp}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Process Is Not Deployed
  [Arguments]  ${app_name}
  ${resp}=  List Processes
  @{processes}=  Get Process Names From Response  ${resp}
  Should Be True  $processes is not None
  Should Not Contain  ${processes}  ${app_name}

Execute Application Success
  [Arguments]  ${app_name}  ${execute_filename}
  ${job_location}=  Execute Application  ${app_name}  ${execute_filename}
  Check Job Status Success  ${job_location}

Execute Application
  [Arguments]  ${app_name}  ${execute_filename}
  ${resp}  ${access_token}  ${job_location} =  Proc Execute App  ${API_PROC_SERVICE_URL}  ${app_name}  ${execute_filename}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Status Should Be  201  ${resp}
  Should Be True  $access_token is not None
  Should Be True  $job_location is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${job_location}

Check Job Status Success
  [Arguments]  ${job_location}
  ${resp}  ${access_token} =  Proc Job Status  ${ADES_BASE_URL}  ${job_location}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  FOR  ${index}  IN RANGE  40
    Sleep  30  Loop wait for processing execution completion
    ${resp}  ${access_token} =  Proc Job Status  ${ADES_BASE_URL}  ${job_location}  ${ID_TOKEN}  ${ACCESS_TOKEN}
    Status Should Be  200  ${resp}
    Should Be True  $access_token is not None
    Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
    ${status}=  Set Variable  ${resp.json()["status"]}
    Exit For Loop If  "${status}" != "running"
  END
  Should Match  ${resp.json()["status"]}  successful
  Should Match  ${resp.json()["message"]}  Done
  Should Match  ${resp.json()["progress"]}  100
