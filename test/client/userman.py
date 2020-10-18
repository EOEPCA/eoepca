import requests
from urllib3.exceptions import InsecureRequestWarning
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST


def init_session():
    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    session = requests.Session()
    session.verify = False
    return session


def get_token_endpoint(session, base_url):
    print("..get_token_endpoint..")
    headers = { 'content-type': "application/json" }
    r = session.get(base_url + "/.well-known/uma2-configuration", headers=headers)
    return r.json()["token_endpoint"]


def register_client(base_url):
    print("..register_scim_client..")
    scim_client = EOEPCA_Scim(base_url + "/")
    client = scim_client.registerClient(
        "Demo Client",
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
