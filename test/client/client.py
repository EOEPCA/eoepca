import requests
from urllib3.exceptions import InsecureRequestWarning
import json
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST

class DemoClient:
    ADMIN_USER="admin"
    ADMIN_PASSWORD="admin_Abcd1234#"

    def __init__(self, base_url):
        self.base_url = base_url
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        self.session = requests.Session()
        self.session.verify = False
        self.token_endpoint = None
        self.scim_client = None
        self.client = None
        self.state = {
            "client_id": None,
            "client_secret": None,
            "resources": {}
        }
    
    def load_state(self):
        pass
    
    def save_state(self):
        print(json.dumps(self.state))

    def get_token_endpoint(self):
        if self.token_endpoint == None:
            headers = { 'content-type': "application/json" }
            r = self.session.get(self.base_url + "/.well-known/uma2-configuration", headers=headers)
            self.token_endpoint = r.json()["token_endpoint"]
            print(f"token_endpoint: {self.token_endpoint}")
        return self.token_endpoint

    def register_client(self):
        if not "client_id" in self.state:
            if self.scim_client == None:
                self.scim_client = EOEPCA_Scim(self.base_url + "/")
            self.client = self.scim_client.registerClient(
                "Demo Client",
                grantTypes = ["client_credentials", "password", "urn:ietf:params:oauth:grant-type:uma-ticket"],
                redirectURIs = [""],
                logoutURI = "",
                responseTypes = ["code","token","id_token"],
                scopes = ['openid',  'email', 'user_name ','uma_protection', 'permission'],
                token_endpoint_auth_method = ENDPOINT_AUTH_CLIENT_POST)
            self.state["client_id"] = self.client["client_id"]
            self.state["client_secret"] = self.client["client_secret"]
            print(f"client_id: {self.state['client_id']}")
        else:
            print(f"client_id: {self.state['client_id']} [REUSED]")

    def get_id_token(self, username, password):
        headers = { 'cache-control': "no-cache" }
        data = {
            "scope": "openid",
            "grant_type": "password",
            "username": username,
            "password": password,
            "client_id": self.state["client_id"],
            "client_secret": self.state["client_secret"]
        }
        r = self.session.post(self.token_endpoint, headers=headers, data=data)
        id_token = r.json()["id_token"]
        print(f"id_token: {id_token}")
        return id_token

    def get_admin_id_token(self):
        return self.get_id_token(DemoClient.ADMIN_USER, DemoClient.ADMIN_PASSWORD)

    def add_resource(self, service_url, uri, id_token, name, scopes):
        resource_id = None
        if "resources" in self.state:
            if service_url in self.state["resources"]:
                if uri in self.state["resources"][service_url]:
                    resource_id = self.state["resources"][service_url][uri]
            else:
                self.state["resources"][service_url] = {}
        else:
            self.state["resources"] = {}
        if resource_id == None:
            headers = { 'content-type': "application/json", "Authorization": "Bearer {id_token}" }
            data = { "resource_scopes":scopes, "icon_uri":uri, "name":name}
            r = self.session.post(f"{service_url}/resources/{name}", headers=headers, json=data)
            resource_id = r.text
            self.state[service_url][uri] = resource_id
            print(f"resource_id: {resource_id}")
        else:
            print(f"resource_id: {resource_id} [REUSED]")
        return resource_id

    def get_uma_ticket(self, service_url, resource_id, id_token):
        headers = { "Authorization": "Bearer {id_token}" }
        r = self.session.get(f"{service_url}/resources/{resource_id}", headers=headers)
        ticket = ""
        if r.status_code == 401:
            location_header = r.headers["WWW-Authenticate"]
            for item in location_header.split(","):
                if item.split("=")[0] == "ticket":
                    ticket = item.split("=")[1]
                    break
        print(f"ticket: {ticket}")
        return ticket

    def get_access_token_from_ticket(self, ticket, id_token):
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
        data = {
            "claim_token_format": "http://openid.net/specs/openid-connect-core-1_0.html#IDToken",
            "claim_token": id_token,
            "ticket": ticket,
            "grant_type": "urn:ietf:params:oauth:grant-type:uma-ticket",
            "client_id": self.state["client_id"],
            "client_secret": self.state["client_secret"],
            "scope": "openid"
        }
        r = self.session.post(self.token_endpoint, headers=headers, data=data)
        access_token = r.json()["access_token"]
        print(f"access_token: {access_token}")
        return access_token

    def get_access_token_from_password(self, username, password):
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
        data = {
            "grant_type": "password",
            "client_id": self.state["client_id"],
            "client_secret": self.state["client_secret"],
            "username": username,
            "password": password,
            "scope": "openid"
        }
        r = self.session.post(self.token_endpoint, headers=headers, data=data)
        access_token = r.json()["access_token"]
        print(f"access_token: {access_token}")
        return access_token

