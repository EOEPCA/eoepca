#! /usr/bin/env python

import userman


def main():
    print("..main..")
    base_url = "https://test.172.17.0.3.nip.io"
    ades_url = "http://ades.test.172.17.0.3.nip.io"
    username = "admin"
    password = "admin_Abcd1234#"

    # session
    session = userman.init_session()

    # token endpoint
    token_endpoint = userman.get_token_endpoint(session, base_url)

    # register client
    client_details = userman.register_client(base_url)
    client_id = client_details["client_id"]
    client_secret = client_details["client_secret"]

    # id token
    id_token = userman.get_id_token(session, token_endpoint, client_id, client_secret)

    # add ADES resource
    resource_id = userman.add_resource(session, ades_url, id_token, "/ades19", "ADES Service", ["Authenticated"])

    # get token to access ADES (admin)
    ticket = userman.get_uma_ticket(session, ades_url, id_token, resource_id)
    access_token = userman.get_access_token_from_ticket(session, token_endpoint, ticket, id_token, client_id, client_secret)

    # get token to access ADES (demo user)
    demo_access_token = userman.get_access_token_from_password(session, token_endpoint, "demo", "telespazio", client_id, client_secret)


if __name__ == "__main__":
    main()
