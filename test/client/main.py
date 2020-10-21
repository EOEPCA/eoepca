#! /usr/bin/env python3

import client


def main():
    print("..main..")
    base_url = "https://test.192.168.49.2.nip.io"
    ades_url = "http://ades.test.192.168.49.2.nip.io"

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
    print("### ADMIN ID TOKEN ###")
    admin_id_token = demo.get_admin_id_token()

    # add ADES resource
    print("### ADD ADES RESOURCE ###")
    resource_id = demo.add_resource(ades_url, "/ades", admin_id_token, "ADES Service", ["Authenticated"])

    # get token to access ADES (admin)
    print("### ADMIN USER TOKENS ###")
    ticket = demo.get_uma_ticket_from_failed_resource_access(f"{ades_url}/ades", admin_id_token)
    admin_access_token = demo.get_access_token_from_ticket(ticket, admin_id_token)

    # get token to access ADES (demo user)
    print("### DEMO USER TOKENS ###")
    demo_id_token = demo.get_id_token("demo", "telespazio")
    ticket = demo.get_uma_ticket_from_failed_resource_access(f"{ades_url}/ades", demo_id_token)
    demo_access_token = demo.get_access_token_from_ticket(ticket, demo_id_token)

    #===========================================================================
    # Processing
    #===========================================================================

    # workarounds
    ades_url_direct = "http://192.168.49.2:30999"
    ades_jwt_example = "eyJhbGciOiJIUzI1NiIsImtpZCI6IlJTQTEifQ.eyJhY3RpdmUiOnRydWUsImV4cCI6MTU5MzUxNTU2NSwiaWF0IjoxNTkzNTExOTY1LCJuYmYiOm51bGwsInBlcm1pc3Npb25zIjpbeyJyZXNvdXJjZV9pZCI6ImI3Y2FkZTVjLTM3MmYtNGM4Ny1iZTgyLWE3OTU2NDk4ZTcyOSIsInJlc291cmNlX3Njb3BlcyI6WyJBdXRoZW50aWNhdGVkIiwib3BlbmlkIl0sImV4cCI6MTU5MzUxNTU2NCwicGFyYW1zIjpudWxsfV0sImNsaWVudF9pZCI6IjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSIsInN1YiI6bnVsbCwiYXVkIjoiNjFjZTI4ZDUtYWExNi00ZGRjLTg0MmYtZmNjMTU4ZDMxNWZhIiwiaXNzIjpudWxsLCJqdGkiOm51bGwsInBjdF9jbGFpbXMiOnsiYXVkIjpbIjYxY2UyOGQ1LWFhMTYtNGRkYy04NDJmLWZjYzE1OGQzMTVmYSJdLCJzdWIiOlsiZWIzMTQyMWUtMGEyZS00OTBmLWJiYWYtMDk3MWE0ZTliNzhhIl0sInVzZXJfbmFtZSI6WyJyaWNvbndheSJdLCJpc3MiOlsiaHR0cHM6Ly9lb2VwY2EtZGV2LmRlaW1vcy1zcGFjZS5jb20iXSwiZXhwIjpbIjE1OTM1MTU1NjQiXSwiaWF0IjpbIjE1OTM1MTE5NjQiXSwib3hPcGVuSURDb25uZWN0VmVyc2lvbiI6WyJvcGVuaWRjb25uZWN0LTEuMCJdfX0.d5qeaqLfl0oh9KigVrM_lT1hZMaOzQBFB7jjaKI3PjE"
    active_ades_url = ades_url_direct
    ades_token = ades_jwt_example
    # active_ades_url = ades_url
    # ades_token = admin_access_token

    # path prefix depending on endpoint
    ades_prefix = ""
    if active_ades_url == ades_url:
        print("### USING /ades PREFIX ###")
        ades_prefix = "/ades"

    # Init ADES
    demo.set_ades_wps_url(active_ades_url + ades_prefix + "/zoo")
    demo.set_ades_proc_url(active_ades_url + ades_prefix + "/wps3")

    # WPS Get Capabilities
    print("### WPS GET CAPABILITIES ###")
    demo.wps_get_capabilities()

    # API Proc List Processes
    print("### API Proc List Processes ###")
    demo.proc_list_processes(ades_token)

    # API Proc Deploy Application
    print("### API Proc Deploy Application ###")
    demo.proc_deploy_application("data/app-deploy-body.json", ades_token)

    # API Proc Get Application Details
    print("### API Proc Get Application Details ###")
    demo.proc_get_app_details("vegetation_index_", ades_token)

    #===========================================================================
    # Completion
    #===========================================================================

    demo.save_state()

if __name__ == "__main__":
    main()
