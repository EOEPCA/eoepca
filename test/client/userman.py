import requests
from urllib3.exceptions import InsecureRequestWarning
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST


ADMIN_USER="admin"
ADMIN_PASSWORD="admin_Abcd1234#"


def init_session():
    requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
    session = requests.Session()
    session.verify = False
    return session


def get_token_endpoint(session, base_url):
    headers = { 'content-type': "application/json" }
    r = session.get(base_url + "/.well-known/uma2-configuration", headers=headers)
    token_endpoint = r.json()["token_endpoint"]
    print(f"token_endpoint: {token_endpoint}")
    return token_endpoint


def register_client(base_url):
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
    print(f"client_id: {details['client_id']}")
    return details


def get_id_token(session, token_endpoint, client_id, client_secret):
    headers = { 'cache-control': "no-cache" }
    data = {
        "scope": "openid",
        "grant_type": "password",
        "username": ADMIN_USER,
        "password": ADMIN_PASSWORD,
        "client_id": client_id,
        "client_secret": client_secret
    }
    r = session.post(token_endpoint, headers=headers, data=data)
    id_token = r.json()["id_token"]
    print(f"id_token: {id_token}")
    return id_token


def add_resource(session, base_url, id_token, uri, name, scopes):
    headers = { 'content-type': "application/json", "Authorization": "Bearer {id_token}" }
    data = { "resource_scopes":scopes, "icon_uri":uri, "name":name}
    r = session.post(f"{base_url}/resources/{name}", headers=headers, json=data)
    resource_id = r.text
    print(f"resource_id: {resource_id}")
    return resource_id


def get_uma_ticket(session, base_url, id_token, resource_id):
    headers = { "Authorization": "Bearer {id_token}" }
    r = session.get(f"{base_url}/resources/{resource_id}", headers=headers)
    ticket = ""
    if r.status_code == 401:
        location_header = r.headers["WWW-Authenticate"]
        for item in location_header.split(","):
            if item.split("=")[0] == "ticket":
                ticket = item.split("=")[1]
                break
    print(f"ticket: {ticket}")
    return ticket


def get_access_token_from_ticket(session, token_endpoint, ticket, claim_token, client_id, client_secret):
    headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
    data = {
        "claim_token_format": "http://openid.net/specs/openid-connect-core-1_0.html#IDToken",
        "claim_token": claim_token,
        "ticket": ticket,
        "grant_type": "urn:ietf:params:oauth:grant-type:uma-ticket",
        "client_id": client_id,
        "client_secret": client_secret,
        "scope": "openid"
    }
    r = session.post(token_endpoint, headers=headers, data=data)
    access_token = r.json()["access_token"]
    print(f"access_token: {access_token}")
    return access_token


def get_access_token_from_password(session, token_endpoint, username, password, client_id, client_secret):
    headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
    data = {
        "grant_type": "password",
        "client_id": client_id,
        "client_secret": client_secret,
        "username": username,
        "password": password,
        "scope": "openid"
    }
    r = session.post(token_endpoint, headers=headers, data=data)
    access_token = r.json()["access_token"]
    print(f"access_token: {access_token}")
    return access_token

