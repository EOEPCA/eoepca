#! /usr/bin/env python

import userman


def main():
    print("..main..")
    base_url = "https://test.172.17.0.3.nip.io"
    username = "admin"
    password = "admin_Abcd1234#"

    # session
    session = userman.init_session()

    # token endpoint
    token_endpoint = userman.get_token_endpoint(session, base_url)
    print("token_endpoint:", token_endpoint)

    # register client
    client_details = userman.register_client(base_url)
    print("client_details:", client_details)

    # id token
    id_token = userman.get_id_token(session, token_endpoint, username, password, client_details["client_id"], client_details["client_secret"])
    print("id_token:", id_token)


if __name__ == "__main__":
    main()
