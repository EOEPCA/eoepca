import requests
from urllib3.exceptions import InsecureRequestWarning
import json
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST

class DemoClient:
    """Example client calling EOEPCA public endpoints
    """
    ADMIN_USER="admin"
    ADMIN_PASSWORD="admin_Abcd1234#"

    def __init__(self, base_url):
        """Initialise client session with provided base URL.
        """
        self.base_url = base_url
        requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)
        self.session = requests.Session()
        self.session.verify = False
        self.token_endpoint = None
        self.scim_client = None
        self.client = None
        self.load_state()
    
    def load_state(self):
        """Load state from file 'state.json'.
        """
        self.state = {}
        try:
            with open("state.json") as state_file:
                self.state = json.loads(state_file.read())
                print(f"State loaded from file: {self.state}")
        except FileNotFoundError:
            pass
        except json.decoder.JSONDecodeError:
            print(f"ERROR loading state from file. Using clean state...")
    
    def save_state(self):
        """Save state to file 'state.json'.
        """
        state_filename = "state.json"
        with open(state_filename, "w") as state_file:
            state_file.write(json.dumps(self.state, sort_keys=True, indent=2))
            print("Client state saved to file:", state_filename)

    def get_token_endpoint(self):
        """Get the URL of the token endpoint.

        Requires no authentication.
        """
        if self.token_endpoint == None:
            headers = { 'content-type': "application/json" }
            r = self.session.get(self.base_url + "/.well-known/uma2-configuration", headers=headers)
            self.token_endpoint = r.json()["token_endpoint"]
            print(f"token_endpoint: {self.token_endpoint}")
        return self.token_endpoint

    def register_client(self):
        """Register ourselves as a client of the platform.

        Uses hardcoded ADMIN credentials.
        Skips registration if client is already registered (client_id/secret loaded from state file).
        """
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
        """Gets a user ID token using username/password authentication.
        """
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
        """Get ID token for ADMIN user using hardcoded credentials
        """
        return self.get_id_token(DemoClient.ADMIN_USER, DemoClient.ADMIN_PASSWORD)

    def add_resource(self, service_url, uri, id_token, name, scopes):
        """Register a resource in the PEP

        Uses provided user ID token to authorise the request.
        Resource is identified by its path (URI).
        Resource is registered with the provided 'nice' name.
        """
        resource_id = None
        if "resources" in self.state:
            if service_url in self.state["resources"]:
                if uri in self.state["resources"][service_url]:
                    resource_id = self.state["resources"][service_url][uri]
            else:
                self.state["resources"][service_url] = { uri: "" }
        else:
            self.state["resources"] = { service_url: { uri: "" } }
        if resource_id == None:
            headers = { 'content-type': "application/json", "Authorization": "Bearer {id_token}" }
            data = { "resource_scopes":scopes, "icon_uri":uri, "name":name}
            r = self.session.post(f"{service_url}/resources/{name}", headers=headers, json=data)
            resource_id = r.text
            self.state["resources"][service_url][uri] = resource_id
            print(f"resource_id: {resource_id}")
        else:
            print(f"resource_id: {resource_id} [REUSED]")
        return resource_id

    def get_access_token_from_ticket(self, ticket, id_token):
        """Convert UMA ticket to access token, using ID token for authentication.
        """
        if ticket == None or len(ticket) == 0 or id_token == None or len(id_token) == 0:
            print("ERROR: ticket and id_token are required")
            return
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
        """Convert UMA ticket to access token, using username/password for authentication.
        """
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

    def set_ades_wps_url(self, url):
        """Set URL to access the ADES 'WPS1.0/2.0' endpoint
        """
        self.ades_wps_url = url

    def set_ades_proc_url(self, url):
        """Set URL to access the ADES 'API Processes' endpoint
        """
        self.ades_proc_url = url

    def uma_get_request(self, requestor, url, headers=None, id_token=None, access_token=None, json=None):
        """Helper to perform a get request via a UMA flow
        """
        # loop control variables
        count = 0
        repeat = True
        # max 2 loops. Repeat if we got a 401 and used UMA to get a new access token
        while repeat and count < 2:
            count += 1
            repeat = False
            # init headers if needed
            if headers is None:
                headers = {}
            # use access token if we have one
            if access_token is not None:
                headers["Authorization"] = f"Bearer {access_token}"
            # attempt access
            r = requestor(url, headers=headers, json=json)
            # if response is OK then nothing else to do
            if r.ok:
                pass
            # if we got a 401 then initiate the UMA flow
            elif r.status_code == 401:
                # need an id token for the UMA flow
                if id_token is not None:
                    # get ticket from the supplied header
                    location_header = r.headers["WWW-Authenticate"]
                    for item in location_header.split(","):
                        if item.split("=")[0] == "ticket":
                            ticket = item.split("=")[1]
                            break
                    # if we have a ticket then request an access token
                    if ticket is not None:
                        access_token = self.get_access_token_from_ticket(ticket, id_token)
                        repeat = True
            # unhandled response code
            else:
                print(f"UNEXPECTED status code: {r.status_code} for resource {url}")
        # return the response and the access token which may be reusable
        return r, access_token

    def wps_get_capabilities(self, id_token=None, access_token=None):
        """Call the WPS GetCapabilities endpoint
        """
        url = self.ades_wps_url + "/?service=WPS&version=1.0.0&request=GetCapabilities"
        r, access_token = self.uma_get_request(self.session.get, url, id_token=id_token, access_token=access_token)
        print(f"[WPS Capabilities]=({r.status_code}-{r.reason})={r.text}")
        return access_token

    def proc_list_processes(self, id_token=None, access_token=None):
        """Call the 'API Processes' endpoint
        """
        url = self.ades_proc_url + "/processes"
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_get_request(self.session.get, url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Process List]=({r.status_code}-{r.reason})={r.text}")
        return access_token

    def proc_deploy_application(self, app_deploy_body_filename, id_token=None, access_token=None):
        """Deploy application via 'API Processes' endpoint, with optional user token

        The body of the deployment request is obtained from the supplied file
        """
        # get request body from file
        app_deploy_body = {}
        try:
            with open(app_deploy_body_filename) as app_deploy_body_file:
                app_deploy_body = json.loads(app_deploy_body_file.read())
                print(f"Application details read from file: {app_deploy_body_filename}")
        except FileNotFoundError:
            print(f"ERROR could not find application details file: {app_deploy_body_filename}")
        except json.decoder.JSONDecodeError:
            print(f"ERROR loading application details from file: {app_deploy_body_filename}")
        # make request
        url = self.ades_proc_url + "/processes"
        headers = { "Accept": "application/json", "Content-Type": "application/json" }
        r, access_token = self.uma_get_request(self.session.post, url, headers=headers, id_token=id_token, access_token=access_token, json=app_deploy_body)
        print(f"[Deploy Response]=({r.status_code}-{r.reason})={r.text}")
        return access_token

    def proc_get_app_details(self, app_name, token=None):
        """Get details for the application with the supplied name, with optional user token
        """
        headers = { "Accept": "application/json" }
        if token:
            headers["Authorization"] = f"Bearer {token}"
        r = self.session.get(self.ades_proc_url + "/processes/" + app_name, headers=headers)
        print(f"[App Details]=({r.status_code}-{r.reason})={r.text}")
