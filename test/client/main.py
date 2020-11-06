#! /usr/bin/env python3

import client


def main():
    print("..main..")
    USER_NAME="demo"
    USER_PASSWORD="telespazio"
    base_url = "https://test.185.52.193.87.nip.io"
    ades_url = "http://ades.test.185.52.193.87.nip.io"

    #===========================================================================
    # UM setup
    #===========================================================================

    # client
    demo = client.DemoClient(base_url)

    # token endpoint
    print("### TOKEN ENDPOINT ###")
    demo.get_token_endpoint()

    # register client
    print("### REGISTER CLIENT ###")
    demo.register_client()

    # id token
    print("### USER ID TOKEN ###")
    user_id_token = demo.get_id_token(USER_NAME, USER_PASSWORD)

    # add ADES resource
    print("### ADD ADES RESOURCE ###")
    demo.add_resource(ades_url, "/zoo", user_id_token, "ADES WPS Service", ["Authenticated"])
    demo.add_resource(ades_url, "/wps3", user_id_token, "ADES API Service", ["Authenticated"])

    # get demo user id token
    # print("### DEMO USER TOKENS ###")
    # demo_id_token = demo.get_id_token("demo", "telespazio")

    #===========================================================================
    # Processing
    #===========================================================================

    # workarounds
    ades_url_direct = "http://185.52.193.87:30999"
    ades_jwt_example = "eyJhbGciOiJIUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTU5MzUxNTU2NSwiaWF0IjoxNTkzNTExOTY1LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6ImI3Y2FkZTVjLTM3MmYtNGM4Ny1iZTgyLWE3OTU2NDk4ZTcyOSIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTU5MzUxNTU2NCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6IjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSIsInN1YiI6bnVsbCwiYXVkIjoiNjFjZTI4ZDUtYWExNi00ZGRjLTg0MmYtZmNjMTU4ZDMxNWZhIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSJdLCJzdWIiOlsiZWIzMTQyMWUtMGEyZS00OTBmLWJiYWYtMDk3MWE0ZTliNzhhIl0sInVzZXJfbmFtZSI6WyJyaWNvbndheSJdLCJpc3MiOlsiaHR0cHM6Ly9lb2VwY2EtZGV2LmRlaW1vcy1zcGFjZS5jb20iXSwiZXhwIjpbIjE1OTM1MTU1NjQiXSwiaWF0IjpbIjE1OTM1MTE5NjQiXSwib3hPcGVuSURDb25uZWN0VmVyc2lvbiI6WyJvcGVuaWRjb25uZWN0LTEuMCJdfX0.d5qeaqLfl0oh9KigVrM_lT1hZMaOzQBFB7jjaKI3PjE"
    jwt_from_pep = "eyJhbGciOiJSUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTYwNDM0MjIzNCwiaWF0IjoxNjA0MzM4NjM0LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6IjZjNThhNWU1LTk1YjctNDRjYS1hYjQ5LWIxMTkyZTBkYjE5OCIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTYwNDM0MjIzNCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6Ijk2M2U0YzJhLTk5MjQtNGM0ZC1iOTk5LWJlYmU3OWM5NmE1ZSIsInN1YiI6bnVsbCwiYXVkIjoiOTYzZTRjMmEtOTkyNC00YzRkLWI5OTktYmViZTc5Yzk2YTVlIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjk2M2U0YzJhLTk5MjQtNGM0ZC1iOTk5LWJlYmU3OWM5NmE1ZSJdLCJzdWIiOlsiNjk0N2RlYWEtNTZjYi00YjM2LTk2ODktYjU4MzA0YjAzNWZlIl0sImlzcyI6WyJodHRwczovL3Rlc3QuMTkyLjE2OC40OS4yLm5pcC5pbyJdLCJleHAiOlsiMTYwNDM0MjIzNCJdLCJpYXQiOlsiMTYwNDMzODYzNCJdLCJveE9wZW5JRENvbm5lY3RWZXJzaW9uIjpbIm9wZW5pZGNvbm5lY3QtMS4wIl19fQ.RcQmVNrt8C4SgxS7eZTbG-Yw_xnFaOY8yNRvZ4n6DqVaAU8daVXl3EwTiVsNNgB_Vr3nG5zrc7kKJXWMgVM-jF-L2B-smMNRzCpwcF0UwJMmZ3iaCpmtuh_AZtB9SqJurLNIYprEnLh1YcMa2RWjxq6pMjGdMKRCE7Z85c3hFB8_TpsAB004VQd_vXxIP7efpE5YhzQwK2N5cYhUsru2PmBuLpPDvSA6wUWxqQyCEF8IWqeR1DBvhmzV_seTFKhT1GdkVUIsB5RnP5A4OBwBkY3oC-b0euI68MtjMas5i_i0f-jmQjc2816DTLhniySAUJBTwDOyx7VlhrEbBmqM_g"
    # active_ades_url = ades_url_direct
    # ades_token = ades_jwt_example
    active_ades_url = ades_url
    # ades_token = admin_access_token

    # path prefix depending on endpoint
    ades_prefix = ""
    if active_ades_url == ades_url:
        print("### USING /ades PREFIX ###")
        ades_prefix = "/ades"

    # Init ADES
    ades_wps_url = active_ades_url + ades_prefix + "/zoo"
    ades_proc_url = active_ades_url + ades_prefix + "/wps3"

    access_token = None

    # WPS Get Capabilities
    print("### WPS GET CAPABILITIES ###")
    access_token = demo.wps_get_capabilities(ades_wps_url, id_token=user_id_token, access_token=access_token)

    # API Proc List Processes
    print("### API Proc List Processes ###")
    access_token = demo.proc_list_processes(ades_proc_url, id_token=user_id_token, access_token=access_token)

    # API Proc Deploy Application
    print("### API Proc Deploy Application ###")
    access_token = demo.proc_deploy_application(ades_proc_url, "data/app-deploy-body.json", id_token=user_id_token, access_token=access_token)

    # API Proc Get Application Details
    print("### API Proc Get Application Details ###")
    app_name = "vegetation_index_"
    access_token = demo.proc_get_app_details(ades_proc_url, app_name, id_token=user_id_token, access_token=access_token)

    #===========================================================================
    # Completion
    #===========================================================================

    demo.save_state()

if __name__ == "__main__":
    main()
