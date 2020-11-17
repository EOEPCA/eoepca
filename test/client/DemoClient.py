import requests
from urllib3.exceptions import InsecureRequestWarning
import json
from urllib.parse import urlparse
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST
from robot.api.deco import library, keyword

@library
class DemoClient:
    """Example client calling EOEPCA public endpoints
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '0.1'

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
    
    @keyword(name='Client Save State')
    def save_state(self):
        """Save state to file 'state.json'.
        """
        state_filename = "state.json"
        with open(state_filename, "w") as state_file:
            state_file.write(json.dumps(self.state, sort_keys=True, indent=2))
            print("Client state saved to file:", state_filename)

    #---------------------------------------------------------------------------
    # USER MANAGEMENT
    #---------------------------------------------------------------------------

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
            if self.client["client_id"] and self.client["client_secret"]:
                self.state["client_id"] = self.client["client_id"]
                self.state["client_secret"] = self.client["client_secret"]
                print(f"client_id: {self.state['client_id']}")
            else:
                print("ERROR: Incomplete client credentials")
        else:
            print(f"client_id: {self.state['client_id']} [REUSED]")

    def get_client_credentials(self):
        """Returns the client credentials (client_id/secret)

        Performs client registration if needed.
        """
        if not "client_id" in self.state:
            self.register_client()
        return self.state["client_id"], self.state["client_secret"]

    @keyword(name='Get ID Token')
    def get_id_token(self, username, password):
        """Gets a user ID token using username/password authentication.
        """
        client_id, client_secret = self.get_client_credentials()
        headers = { 'cache-control': "no-cache" }
        data = {
            "scope": "openid user_name",
            "grant_type": "password",
            "username": username,
            "password": password,
            "client_id": client_id,
            "client_secret": client_secret
        }
        r = self.session.post(self.get_token_endpoint(), headers=headers, data=data)
        id_token = r.json()["id_token"]
        print(f"id_token: {id_token}")
        return id_token

    @keyword(name='Register Protected Resource')
    def register_protected_resource(self, service_url, uri, id_token, name, scopes):
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
                self.state["resources"][service_url] = {}
        else:
            self.state["resources"] = { service_url: {} }
        if resource_id == None:
            headers = { 'content-type': "application/json", "Authorization": f"Bearer {id_token}" }
            data = { "resource_scopes":scopes, "icon_uri":uri, "name":name}
            r = self.session.post(f"{service_url}/resources/{name}", headers=headers, json=data)
            resource_id = r.text
            if resource_id:
                self.state["resources"][service_url][uri] = resource_id
                print(f"resource_id: {resource_id} ({service_url}{uri})")
            else:
                print(f"ERROR: Empty resource ID for {service_url}{uri}")
        else:
            print(f"resource_id: {resource_id} ({service_url}{uri}) [REUSED]")
        return resource_id

    def get_access_token_from_ticket(self, ticket, id_token):
        """Convert UMA ticket to access token, using ID token for authentication.
        """
        if ticket == None or len(ticket) == 0 or id_token == None or len(id_token) == 0:
            print("ERROR: ticket and id_token are required")
            return
        client_id, client_secret = self.get_client_credentials()
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
        data = {
            "claim_token_format": "http://openid.net/specs/openid-connect-core-1_0.html#IDToken",
            "claim_token": id_token,
            "ticket": ticket,
            "grant_type": "urn:ietf:params:oauth:grant-type:uma-ticket",
            "client_id": client_id,
            "client_secret": client_secret,
            "scope": "openid"
        }
        r = self.session.post(self.get_token_endpoint(), headers=headers, data=data)
        access_token = r.json()["access_token"]
        print(f"access_token: {access_token}")
        return access_token

    def get_access_token_from_password(self, username, password):
        """Convert UMA ticket to access token, using username/password for authentication.
        """
        client_id, client_secret = self.get_client_credentials()
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache" }
        data = {
            "grant_type": "password",
            "client_id": client_id,
            "client_secret": client_secret,
            "username": username,
            "password": password,
            "scope": "openid"
        }
        r = self.session.post(self.get_token_endpoint(), headers=headers, data=data)
        access_token = r.json()["access_token"]
        print(f"access_token: {access_token}")
        return access_token

    def uma_http_request(self, requestor, url, headers=None, id_token=None, access_token=None, json=None, data=None):
        """Helper to perform an http request via a UMA flow.

        Handles response code 401 to perform the UMA flow.
        The 'requestor' argument provides the function to be called to make the request, e.g. `requests.get`, `requests.post`, ...
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
            r = requestor(url, headers=headers, json=json, data=data)
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

    #---------------------------------------------------------------------------
    # ADES WPS
    #---------------------------------------------------------------------------

    @keyword(name='WPS Get Capabilities')
    def wps_get_capabilities(self, service_base_url, id_token=None, access_token=None):
        """Call the WPS GetCapabilities endpoint
        """
        url = service_base_url + "/?service=WPS&version=1.0.0&request=GetCapabilities"
        r, access_token = self.uma_http_request(self.session.get, url, id_token=id_token, access_token=access_token)
        print(f"[WPS Capabilities]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    #---------------------------------------------------------------------------
    # ADES API PROCESSES
    #---------------------------------------------------------------------------

    @keyword(name='Proc List Processes')
    def proc_list_processes(self, service_base_url, id_token=None, access_token=None):
        """Call the 'API Processes' endpoint
        """
        url = service_base_url + "/processes"
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request(self.session.get, url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Process List]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    @keyword(name='Proc Deploy App')
    def proc_deploy_application(self, service_base_url, app_deploy_body_filename, id_token=None, access_token=None):
        """Deploy application via 'API Processes' endpoint

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
        url = service_base_url + "/processes"
        headers = { "Accept": "application/json", "Content-Type": "application/json" }
        r, access_token = self.uma_http_request(self.session.post, url, headers=headers, id_token=id_token, access_token=access_token, json=app_deploy_body)
        print(f"[Deploy Response]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    @keyword(name='Proc App Details')
    def proc_get_app_details(self, service_base_url, app_name, id_token=None, access_token=None):
        """Get details for the application with the supplied name
        """
        url = service_base_url + "/processes/" + app_name
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request(self.session.get, url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[App Details]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    @keyword(name='Proc Execute App')
    def proc_execute_application(self, service_base_url, app_name, app_execute_body_filename, id_token=None, access_token=None):
        """Execute application via 'API Processes' endpoint

        The body of the execute request is obtained from the supplied file
        """
        # get request body from file
        app_execute_body = {}
        try:
            with open(app_execute_body_filename) as app_execute_body_file:
                app_execute_body = json.loads(app_execute_body_file.read())
                print(f"Application execute details read from file: {app_execute_body_filename}")
        except FileNotFoundError:
            print(f"ERROR could not find application execute details file: {app_execute_body_filename}")
        except json.decoder.JSONDecodeError:
            print(f"ERROR loading application execute details from file: {app_execute_body_filename}")
        # make request
        url = service_base_url + "/processes/" + app_name + "/jobs"
        headers = { "Accept": "application/json", "Content-Type": "application/json", "Prefer": "respond-async" }
        r, access_token = self.uma_http_request(self.session.post, url, headers=headers, id_token=id_token, access_token=access_token, json=app_execute_body)
        job_location = r.headers['Location']
        print(f"[Execute Response]=({r.status_code}-{r.reason})=> job={job_location}")
        return r, access_token, job_location

    @keyword(name='Proc Job Status')
    def proc_get_job_status(self, service_base_url, job_location, id_token=None, access_token=None):
        """Get the job status from the supplied location
        """
        url = service_base_url + job_location
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request(self.session.get, url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Job Status]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    def proc_get_job_result(self, service_base_url, job_location, id_token=None, access_token=None):
        """Get the job result from the supplied location
        """
        url = service_base_url + job_location + "/result"
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request(self.session.get, url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Job Result]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token

    @keyword(name='Proc Undeploy App')
    def proc_undeploy_application(self, service_base_url, app_name, app_undeploy_body_filename, id_token=None, access_token=None):
        """Undeploy application via 'API Processes' endpoint

        The body of the undeployment request is obtained from the supplied file
        """
        # get request body from file
        app_undeploy_body = {}
        try:
            with open(app_undeploy_body_filename) as app_undeploy_body_file:
                app_undeploy_body = json.loads(app_undeploy_body_file.read())
                print(f"Undeployment details read from file: {app_undeploy_body_filename}")
        except FileNotFoundError:
            print(f"ERROR could not find undeploy details file: {app_undeploy_body_filename}")
        except json.decoder.JSONDecodeError:
            print(f"ERROR loading undeploy details from file: {app_undeploy_body_filename}")
        # make request
        url = service_base_url + "/processes/" + app_name
        headers = { "Accept": "application/json", "Content-Type": "application/json" }
        r, access_token = self.uma_http_request(self.session.delete, url, headers=headers, id_token=id_token, access_token=access_token, json=app_undeploy_body)
        print(f"[Undeploy Response]=({r.status_code}-{r.reason})={r.text}")
        return r, access_token
