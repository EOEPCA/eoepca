*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
Library  RequestsLibrary
Library  Collections
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${USERNAME}=  ${USER_A_NAME}
${PASSWORD}=  ${USER_A_PASSWORD}
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
  Deploy Application  ${CURDIR}${/}data/app-deploy-body-cwl.json
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
  ${resp}  @{processes} =  List Processes
  Should Be True  $processes is not None
  Set Suite Variable  ${INITIAL_PROCESS_LIST}  ${processes}

List Processes
  ${resp}  ${access_token}  @{processes} =  Proc List Processes  ${API_PROC_SERVICE_URL}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Be Equal As Integers  200  ${resp.status_code}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${resp}  @{processes}

Get Application Details
  [Arguments]  ${app_name}
  ${resp}  ${access_token} =  Proc App Details  ${API_PROC_SERVICE_URL}  ${app_name}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Be Equal As Integers  200  ${resp.status_code}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Deploy Application
  [Arguments]  ${app_filename}
  ${resp}  ${access_token} =  Proc Deploy App  ${API_PROC_SERVICE_URL}  ${app_filename}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Be Equal As Integers  201  ${resp.status_code}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Process Is Deployed
  [Arguments]  ${app_name}
  ${resp}  @{processes} =  List Processes
  Should Be True  $processes is not None
  Should Contain  @{processes}  ${app_name}

Undeploy Application
  [Arguments]  ${app_name}
  ${resp}  ${access_token} =  Proc Undeploy App  ${API_PROC_SERVICE_URL}  ${app_name}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Be Equal As Integers  200  ${resp.status_code}
  Should Be True  $access_token is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}

Process Is Not Deployed
  [Arguments]  ${app_name}
  ${resp}  @{processes} =  List Processes
  Should Be True  $processes is not None
  Should Not Contain  ${processes}  ${app_name}

Execute Application Success
  [Arguments]  ${app_name}  ${execute_filename}
  ${job_location}=  Execute Application  ${app_name}  ${execute_filename}
  Sleep  10  Waiting for job status endpoint to be ready
  Check Job Status Success  ${job_location}

Execute Application
  [Arguments]  ${app_name}  ${execute_filename}
  ${resp}  ${access_token}  ${job_location} =  Proc Execute App  ${API_PROC_SERVICE_URL}  ${app_name}  ${execute_filename}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Be Equal As Integers  201  ${resp.status_code}
  Should Be True  $access_token is not None
  Should Be True  $job_location is not None
  Set Suite Variable  ${ACCESS_TOKEN}  ${access_token}
  [Return]  ${job_location}

Check Job Status Success
  [Arguments]  ${job_location}
  ${interval}=  Set Variable  30
  ${resp}  ${access_token}  ${status} =  Proc Poll Job Completion  ${ADES_BASE_URL}  ${job_location}  ${interval}  ${ID_TOKEN}  ${ACCESS_TOKEN}
  Should Match  ${resp.json()["status"]}  successful
  Should Match  ${resp.json()["message"]}  Done
  Should Match  ${resp.json()["progress"]}  100
