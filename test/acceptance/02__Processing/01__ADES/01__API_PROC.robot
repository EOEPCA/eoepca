*** Settings ***
Documentation  Tests for the ADES OGC API Processes endpoint
# Resource  ADES.resource
# Library  OperatingSystem
# Library  String
# Library  Process
Library  RequestsLibrary
Library  Collections
# Library  ./DemoClient.py  ${UM_BASE_URL}
Library  ../../../client/DemoClient.py  ${UM_BASE_URL}

Suite Setup  Suite Setup
Suite Teardown  Suite Teardown


*** Variables ***
${PEP_PREFIX}=  /ades
${API_PROC_SERVICE_ROOT}=  /wps3
${API_PROC_JOB_MONITOR_ROOT}=  /watchjob
${API_PROC_PATH_PREFIX}=  ${PEP_PREFIX}${API_PROC_SERVICE_ROOT}
${API_PROC_SERVICE_URL}=  ${ADES_BASE_URL}${API_PROC_PATH_PREFIX}
${USERNAME}=  UserA
${PASSWORD}=  defaultPWD
${ID_TOKEN}=
${ACCESS_TOKEN}=


*** Test Cases ***
Initial Process List
  Initial Process List

Deploy Application
  Deploy Application  ${CURDIR}${/}data/app-deploy-body.json
  Sleep  5  Waiting for process deploy process to complete asynchronously
  Process Is Deployed  vegetation_index_

Get Application Details
  Get Application Details  vegetation_index_

Execute Application
  Execute Application Success  vegetation_index_  ${CURDIR}${/}data/app-execute-body.json


*** Keywords ***
Suite Setup
  Init ID Token  ${USERNAME}  ${PASSWORD}
  Init Resource Protection

Suite Teardown
  Client Save State

Init ID Token
  [Arguments]  ${username}  ${password}
  ${id_token}=  Get ID Token  ${username}  ${password}
  Should Be True  $id_token is not None
  Set Suite Variable  ${ID_TOKEN}  ${id_token}

Init Resource Protection
  @{scopes}=  Create List  Authenticated
  ${resource_id}  Register Protected Resource  ${ADES_BASE_URL}  ${API_PROC_SERVICE_ROOT}  ${ID_TOKEN}  ADES API Service  ${scopes}
  Should Be True  $resource_id is not None
  ${resource_id}  Register Protected Resource  ${ADES_BASE_URL}  ${API_PROC_JOB_MONITOR_ROOT}  ${ID_TOKEN}  ADES Job Monitor  ${scopes}
  Should Be True  $resource_id is not None

Initial Process List
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
  ${json}=  Set Variable  ${resp.json()}
  ${process_names}=  Create List
  FOR  ${process}  IN  @{json["processes"]}
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
