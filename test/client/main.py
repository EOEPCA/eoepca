#! /usr/bin/env python

import client


def main():
    print("..main..")
    base_url = "https://test.172.17.0.3.nip.io"
    ades_url = "http://ades.test.172.17.0.3.nip.io"

    # client
    demo = client.DemoClient(base_url)

    # token endpoint
    demo.get_token_endpoint()

    # register client
    demo.register_client()

    # id token
    admin_id_token = demo.get_admin_id_token()

    # add ADES resource
    resource_id = demo.add_resource(ades_url, "/ades", admin_id_token, "ADES Service", ["Authenticated"])

    # get token to access ADES (admin)
    ticket = demo.get_uma_ticket(ades_url, resource_id, admin_id_token)
    admin_access_token = demo.get_access_token_from_ticket(ticket, admin_id_token)

    # get token to access ADES (demo user)
    demo_access_token = demo.get_access_token_from_password("demo", "telespazio")

    demo.save_state()

if __name__ == "__main__":
    main()
