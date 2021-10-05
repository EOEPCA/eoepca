#! /usr/bin/env python3

import DemoClient as client
from time import sleep
import json

def main():
    print("\n### TEST CLIENT ###")
    USER_NAME="eric"
    USER_PASSWORD="defaultPWD"
    domain = "demo.eoepca.org"
    base_url = "https://test." + domain

    # ades
    ades_resource_api_url = "http://ades-pepapi.test." + domain
    ades_url = "https://ades.test." + domain
    ades_user = USER_NAME
    ades_user_prefix = "/" + ades_user

    # workspace-api
    wsapi_resource_api_url = "http://workspace-api-pepapi.test." + domain
    wsapi_url = "https://workspace-api.test." + domain
    wsapi_user = USER_NAME
    wsapi_prefix = "demo-user"
    wsapi_user_prefix = "/workspaces/" + wsapi_prefix + "-" + wsapi_user

    # dummy service
    dummy_resource_api_url = "http://dummy-service-pepapi.test." + domain
    dummy_url = "https://dummy-service.test." + domain

    #===========================================================================
    # UM setup
    #===========================================================================

    # client
    demo = client.DemoClient(base_url)

    # token endpoint
    print("\n### TOKEN ENDPOINT ###")
    demo.get_token_endpoint()

    # register client
    print("\n### REGISTER CLIENT ###")
    demo.register_client()
    
    # id token
    print("\n### USER ID TOKEN ###")
    user_id_token = demo.get_id_token(USER_NAME, USER_PASSWORD)
    print(user_id_token)

    # Register user's ADES base path as an owned resource
    print("\n### REGISTER USER'S ADES BASE RESOURCE PATH ###")
    demo.register_protected_resource(ades_resource_api_url, ades_user_prefix, user_id_token, f"ADES Service for user {USER_NAME}", [])

    # Register Workspace API Swagger docs as public access
    operator_id_token = demo.get_id_token("operator", USER_PASSWORD)
    print("\n### REGISTER Workspace API Swagger Docs as Public Access ###")
    demo.register_protected_resource(wsapi_resource_api_url, "/docs", operator_id_token, f"Workspace API Swagger Docs", ["public_access"])

    # Register user's Workspace base path as an owned resource
    print("\n### REGISTER USER'S Workspace BASE RESOURCE PATH ###")
    demo.register_protected_resource(wsapi_resource_api_url, wsapi_user_prefix, user_id_token, f"Workspace for user {USER_NAME}", [])

    #===========================================================================
    # Dummy Service
    #===========================================================================

    dummy_access_token = None

    # Call Dummy Service
    print("\n### Dummy Service ###")
    demo.trace_flow = True
    response, dummy_access_token = demo.dummy_service_call(dummy_url + "/test", id_token=user_id_token, access_token=dummy_access_token)
    demo.trace_flow = False
    print(f"\nSummary of request proxied via the PEP...\n{response.text}\n")

    #===========================================================================
    # Workspace API
    #===========================================================================

    wsapi_user_url = wsapi_url + wsapi_user_prefix
    wsapi_access_token = None

    # Workspace: Create
    print("\n### Workspace: Create ###")
    demo.trace_flow = True
    response, wsapi_access_token = demo.wsapi_create(wsapi_url, wsapi_user, id_token=user_id_token, access_token=wsapi_access_token)
    demo.trace_flow = False
    print(f"DETAILS = {json.dumps(response.json(), indent = 2)}\n")

    # Workspace: Get Details
    print("\n### Workspace: Get Details ###")
    demo.trace_flow = True
    response, wsapi_access_token = demo.wsapi_get_details(wsapi_user_url, id_token=user_id_token, access_token=wsapi_access_token)
    demo.trace_flow = False
    print(f"DETAILS = {json.dumps(response.json(), indent = 2)}\n")

    # Workspace: Get Details - as user bob
    # id token
    print("\n### BOB ID TOKEN ###")
    bob_id_token = demo.get_id_token("bob", USER_PASSWORD)
    print("\n### Workspace: Get Details as user bob ###")
    demo.trace_flow = True
    response, wsapi_access_token = demo.wsapi_get_details(wsapi_user_url, id_token=bob_id_token, access_token=wsapi_access_token)
    demo.trace_flow = False
    # print(f"DETAILS = {json.dumps(response.json(), indent = 2)}\n")

    #===========================================================================
    # Processing
    #===========================================================================

    # workarounds
    # ades_url_direct = "http://ades." + domain + "/testuser"
    # ades_jwt_example = "eyJhbGciOiJIUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTU5MzUxNTU2NSwiaWF0IjoxNTkzNTExOTY1LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6ImI3Y2FkZTVjLTM3MmYtNGM4Ny1iZTgyLWE3OTU2NDk4ZTcyOSIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTU5MzUxNTU2NCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6IjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSIsInN1YiI6bnVsbCwiYXVkIjoiNjFjZTI4ZDUtYWExNi00ZGRjLTg0MmYtZmNjMTU4ZDMxNWZhIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSJdLCJzdWIiOlsiZWIzMTQyMWUtMGEyZS00OTBmLWJiYWYtMDk3MWE0ZTliNzhhIl0sInVzZXJfbmFtZSI6WyJyaWNvbndheSJdLCJpc3MiOlsiaHR0cHM6Ly9lb2VwY2EtZGV2LmRlaW1vcy1zcGFjZS5jb20iXSwiZXhwIjpbIjE1OTM1MTU1NjQiXSwiaWF0IjpbIjE1OTM1MTE5NjQiXSwib3hPcGVuSURDb25uZWN0VmVyc2lvbiI6WyJvcGVuaWRjb25uZWN0LTEuMCJdfX0.d5qeaqLfl0oh9KigVrM_lT1hZMaOzQBFB7jjaKI3PjE"
    # jwt_from_pep = "eyJhbGciOiJSUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTYwNDM0MjIzNCwiaWF0IjoxNjA0MzM4NjM0LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6IjZjNThhNWU1LTk1YjctNDRjYS1hYjQ5LWIxMTkyZTBkYjE5OCIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTYwNDM0MjIzNCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6Ijk2M2U0YzJhLTk5MjQtNGM0ZC1iOTk5LWJlYmU3OWM5NmE1ZSIsInN1YiI6bnVsbCwiYXVkIjoiOTYzZTRjMmEtOTkyNC00YzRkLWI5OTktYmViZTc5Yzk2YTVlIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjk2M2U0YzJhLTk5MjQtNGM0ZC1iOTk5LWJlYmU3OWM5NmE1ZSJdLCJzdWIiOlsiNjk0N2RlYWEtNTZjYi00YjM2LTk2ODktYjU4MzA0YjAzNWZlIl0sImlzcyI6WyJodHRwczovL3Rlc3QuMTkyLjE2OC40OS4yLm5pcC5pbyJdLCJleHAiOlsiMTYwNDM0MjIzNCJdLCJpYXQiOlsiMTYwNDMzODYzNCJdLCJveE9wZW5JRENvbm5lY3RWZXJzaW9uIjpbIm9wZW5pZGNvbm5lY3QtMS4wIl19fQ.RcQmVNrt8C4SgxS7eZTbG-Yw_xnFaOY8yNRvZ4n6DqVaAU8daVXl3EwTiVsNNgB_Vr3nG5zrc7kKJXWMgVM-jF-L2B-smMNRzCpwcF0UwJMmZ3iaCpmtuh_AZtB9SqJurLNIYprEnLh1YcMa2RWjxq6pMjGdMKRCE7Z85c3hFB8_TpsAB004VQd_vXxIP7efpE5YhzQwK2N5cYhUsru2PmBuLpPDvSA6wUWxqQyCEF8IWqeR1DBvhmzV_seTFKhT1GdkVUIsB5RnP5A4OBwBkY3oC-b0euI68MtjMas5i_i0f-jmQjc2816DTLhniySAUJBTwDOyx7VlhrEbBmqM_g"
    # active_ades_url = ades_url_direct
    active_ades_url = ades_url

    # path prefix depending on endpoint
    ades_prefix = ades_user_prefix
    # if active_ades_url == ades_url:
    #     print("\n### USING /ades PREFIX ###")
    #     ades_prefix = "/ades"

    # Init ADES
    ades_wps_url = active_ades_url + ades_prefix + "/zoo"
    ades_proc_url = active_ades_url + ades_prefix + "/wps3"

    access_token = None

    #===========================================================================
    # API Processes
    #===========================================================================

    # API Proc List Processes
    print("\n### API Proc List Processes ###")
    response, access_token, process_ids = demo.proc_list_processes(ades_proc_url, id_token=user_id_token, access_token=access_token)
    print("Process List =", process_ids)

    # API Proc Deploy Application
    print("\n### API Proc Deploy Application ###")
    #
    # ...by atom feed (application/atom+xml) - with entry containing an OGC OWS Context Offering with application/cwl content...
    #response, access_token = demo.proc_deploy_application(ades_proc_url, "../acceptance/02__Processing/01__ADES/data/app-deploy-body-atom.json", id_token=user_id_token, access_token=access_token)
    #
    # ...pure CWL (application/cwl)...
    #response, access_token = demo.proc_deploy_application(ades_proc_url, "../acceptance/02__Processing/01__ADES/data/app-deploy-body-cwl.json", id_token=user_id_token, access_token=access_token)
    # ...same as above but with the cwl stored in a S3 repository
    response, access_token = demo.proc_deploy_application(ades_proc_url, "../acceptance/02__Processing/01__ADES/data/app-deploy-body-cwl-S3.json", id_token=user_id_token, access_token=access_token)
    print("Deploy Response =", response.text)

    # API Proc Get Application Details
    sleep(5)  # give the ades a chance to deploy before proceeding
    print("\n### API Proc Get Application Details ###")
    app_name = "s-expression-0_0_2"
    response, access_token = demo.proc_get_app_details(ades_proc_url, app_name, id_token=user_id_token, access_token=access_token)
    print("Application Details =", response.text)
    
    # API Proc Execute Application
    print("\n### API Proc Execute Application ###")
    app_name = "s-expression-0_0_2"
    response, access_token, job_location_path = demo.proc_execute_application(ades_proc_url, app_name, "../acceptance/02__Processing/01__ADES/data/app-execute-body.json", id_token=user_id_token, access_token=access_token)

    # API Proc Get Job Status
    sleep(5)  # give the ades a chance to register (with the UM) the job status endpoint
    print("\n### API Proc Get Job Status ###")
    response, access_token, status = demo.proc_get_job_status(active_ades_url, job_location_path, id_token=user_id_token, access_token=access_token)
    print("Job Status Response =", response.text)

    # API Proc Poll for Job completion
    print("\n### API Proc Poll for Job completion ###")
    poll_interval = 30
    response, access_token, status = demo.proc_poll_job_completion(active_ades_url, job_location_path, interval=poll_interval, id_token=user_id_token, access_token=access_token)

    # API Proc Get Job Result
    print("\n### API Proc Get Job Result ###")
    r, access_token, stacCatalogUri = demo.proc_get_job_result(active_ades_url, job_location_path, id_token=user_id_token, access_token=access_token)
    response = r.json()
    print("Results STAC file =", stacCatalogUri)

    # API Proc Undeploy Application
    print("\n### API Proc Undeploy Application ###")
    app_name = "s-expression-0_0_2"
    response, access_token = demo.proc_undeploy_application(ades_proc_url, app_name, id_token=user_id_token, access_token=access_token)
    print("Undeploy Response =", response.text)

    #===========================================================================
    # WPS
    #===========================================================================

    # WPS Get Capabilities
    print("\n### WPS GET CAPABILITIES ###")
    response, access_token = demo.wps_get_capabilities(ades_wps_url, id_token=user_id_token, access_token=access_token)

    #===========================================================================
    # Completion
    #===========================================================================

    demo.save_state()

if __name__ == "__main__":
    main()
