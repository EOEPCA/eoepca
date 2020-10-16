import requests
from urllib3.exceptions import InsecureRequestWarning
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST


def get_token_endpoint(session, base_url):
    print("..get_token_endpoint..")
    headers = { 'content-type': "application/json" }
    r = session.get(base_url + "/.well-known/uma2-configuration", headers=headers)
    return r.json()["token_endpoint"]


def register_scim_client(base_url):
    print("..register_scim_client..")
    scim_client = EOEPCA_Scim(base_url + "/")
    client = scim_client.registerClient(
        "UMA Flow Test Client",
        grantTypes = ["client_credentials", "password", "urn:ietf:params:oauth:grant-type:uma-ticket"],
        redirectURIs = [""],
        logoutURI = "",
        responseTypes = ["code","token","id_token"],
        scopes = ['openid',  'email', 'user_name ','uma_protection', 'permission'],
        token_endpoint_auth_method = ENDPOINT_AUTH_CLIENT_POST)
    details = {}
    details["client_id"] = client["client_id"]
    details["client_secret"] = client["client_secret"]
    return details


def get_id_token(session, token_endpoint, username, password, client_id, client_secret):
    print("..get_id_token..")
    # curl -k -v -XPOST "$TOKEN_ENDPOINT"
    # -H "cache-control: no-cache"
    # -d "scope=openid&grant_type=password&username=admin&password=admin_Abcd1234%23&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET"
    # > ./01__UserManagement/01__LoginService/1.txt
    headers = { 'cache-control': "no-cache" }
    data = {
        "scope": "openid",
        "grant_type": "password",
        "username": username,
        "password": password,
        "client_id": client_id,
        "client_secret": client_secret
    }
    r = session.post(token_endpoint, headers=headers, data=data)
    return r.json()["id_token"]


def main():
    print("..main..")
    um_base_url = "https://test.172.17.0.3.nip.io"
    username = "admin"
    password = "admin_Abcd1234#"

    # session
    session = requests.Session()
    session.verify = False

    # token endpoint
    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    token_endpoint = get_token_endpoint(session, um_base_url)
    print("token_endpoint:", token_endpoint)

    # scim client
    scim_client_details = register_scim_client(um_base_url)
    print("scim_client_details:", scim_client_details)

    # id token
    id_token = get_id_token(session, token_endpoint, username, password, scim_client_details["client_id"], scim_client_details["client_secret"])
    print("id_token:", id_token)


if __name__ == "__main__":
    main()
