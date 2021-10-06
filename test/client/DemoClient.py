import requests
import base64
import os 
import sys
from time import sleep
from datetime import datetime
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
        self.trace_flow = False
        self.trace_requests = True
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

    def trace(self, prefix, message):
        """Debug function to log a trace of execution flow (e.g. for UMA flow)
        """
        if self.trace_flow:
            print(f"[{prefix}] {message}")

    def http_request(self, method, url, **kwargs):
        """Wrapper for requests.session.request() to optionally include logging of the request details
        """
        if self.trace_requests:
            print(f"[Request] {method} => {url}")
        return self.session.request(method, url, **kwargs)

    #---------------------------------------------------------------------------
    # USER MANAGEMENT
    #---------------------------------------------------------------------------

    def get_token_endpoint(self):
        """Get the URL of the token endpoint.

        Requires no authentication.
        """
        if self.token_endpoint == None:
            headers = { 'content-type': "application/json" }
            r = self.http_request("GET", self.base_url + "/.well-known/uma2-configuration", headers=headers)
            print(r)
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
                scopes = ['openid',  'email', 'user_name ','uma_protection', 'permission', 'is_operator'],
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
            "scope": "openid user_name is_operator",
            "grant_type": "password",
            "username": username,
            "password": password,
            "client_id": client_id,
            "client_secret": client_secret
        }
        r = self.http_request("POST", self.get_token_endpoint(), headers=headers, data=data)
        id_token = r.json()["id_token"]
        return id_token

    @keyword(name='Register Protected Resource')
    def register_protected_resource(self, resource_api_url, uri, id_token, name, scopes, ownershipId=None):
        """Register a resource in the PEP

        Uses provided user ID token to authorise the request.
        Resource is identified by its path (URI).
        Resource is registered with the provided 'nice' name.
        """
        resource_id = None
        if "resources" in self.state:
            if resource_api_url in self.state["resources"]:
                if uri in self.state["resources"][resource_api_url]:
                    resource_id = self.state["resources"][resource_api_url][uri]
            else:
                self.state["resources"][resource_api_url] = {}
        else:
            self.state["resources"] = { resource_api_url: {} }
        if resource_id == None:
            headers = { 'content-type': "application/json", "Authorization": f"Bearer {id_token}" }
            data = { "resource_scopes":scopes, "icon_uri":uri, "name":name}
            if ownershipId != None:
                data["uuid"] = ownershipId
            r = self.http_request("POST", f"{resource_api_url}/resources", headers=headers, json=data)

            # Handle based-upon response code
            if r.status_code == 200:
                try:
                    response_json = json.loads(r.text)
                    resource_id= response_json['id']
                except Exception as e:
                    print(f"WARNING: registration of resource '{uri}' appears successful, but could not parse response body: {e}")
            elif r.status_code == 422:
                print(f"Resource '{uri}' is already registered")
                print('Response: ' + str(r))

            # Persist the resource id
            if resource_id:
                self.state["resources"][resource_api_url][uri] = resource_id
                print(f"resource_id: {resource_id} @{resource_api_url} = {uri}")
            else:
                print(f"ERROR: Empty resource ID for {uri} @{resource_api_url}")
        else:
            print(f"resource_id: {resource_id} @{resource_api_url} = {uri} [REUSED]")
        return resource_id

    def get_access_token_from_ticket(self, ticket, id_token):
        """Convert UMA ticket to access token, using ID token for authentication.
        """
        log_prefix = "UMA"
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
        token_endpoint = self.get_token_endpoint()
        self.trace(log_prefix, f"Calling token endpoint with ID Token + ticket: POST => {token_endpoint}")
        r = self.http_request("POST", token_endpoint, headers=headers, data=data)
        try:
            access_token = r.json()["access_token"]
            self.trace(log_prefix, "Successfully exchanged ticket for RPT")
        except:
            self.trace(log_prefix, "ERROR - exchanging ticket for RPT")
            return None
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
        r = self.http_request("POST", self.get_token_endpoint(), headers=headers, data=data)
        access_token = r.json()["access_token"]
        return access_token

    def uma_http_request(self, method, url, headers=None, id_token=None, access_token=None, json=None, data=None):
        """Helper to perform an http request via a UMA flow.

        Handles response code 401 to perform the UMA flow.
        The 'method' argument provides the function to be called to make the request, e.g. `requests.get`, `requests.post`, ...
        """
        log_prefix = "UMA"
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
            # Set ID Token in header
            headers["X-User-Id"] = id_token
            # use access token if we have one
            if access_token is not None:
                self.trace(log_prefix, "Attempting to use existing access token")
                headers["Authorization"] = f"Bearer {access_token}"
            else:
                self.trace(log_prefix, "No existing access token - making a naive attempt")
            # attempt access
            r = self.http_request(method, url, headers=headers, json=json, data=data)
            # if response is OK then nothing else to do
            if r.ok:
                self.trace(log_prefix, "Successfully accessed resource")
            # if we got a 401 then initiate the UMA flow
            elif r.status_code == 401:
                self.trace(log_prefix, "Received a 401 (Unauthorized) response to access attempt")
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
                        self.trace(log_prefix, "Got ticket from response. Using ID Token + ticket to request an RPT")
                        access_token = self.get_access_token_from_ticket(ticket, id_token)
                        repeat = True
                else:
                    self.trace(log_prefix, "No ID Token, so cannot proceed with UMA flow")
            # unhandled response code
            else:
                print(f"UNEXPECTED status code: {r.status_code} for resource {url}")
        # return the response and the access token which may be reusable
        return r, access_token

    #---------------------------------------------------------------------------
    # Dummy Service
    #---------------------------------------------------------------------------

    @keyword(name='Dummy Service Call')
    def dummy_service_call(self, service_base_url, id_token=None, access_token=None):
        """Call the 'Dummy Service' endpoint
        """
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", service_base_url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Dummy Service] = {r.status_code} ({r.reason})")
        return r, access_token

    #---------------------------------------------------------------------------
    # Workspace API : Get Details
    #---------------------------------------------------------------------------

    @keyword(name='Workspace API Create')
    def wsapi_create(self, service_base_url, name, id_token=None, access_token=None):
        """Call the 'Workspace API Create' endpoint
        """
        headers = { "Accept": "application/json" }
        body_data = {}
        body_data["preferred_name"] = name
        r, access_token = self.uma_http_request("POST", service_base_url + "/workspaces", headers=headers, id_token=id_token, access_token=access_token, json=body_data)
        print(f"[Workspace API Create] = {r.status_code} ({r.reason})")
        # process_ids = []
        # if r.status_code == 200:
        #     for process in r.json():
        #         process_ids.append(process['id'])
        return r, access_token

    @keyword(name='Workspace API Get Details')
    def wsapi_get_details(self, service_base_url, id_token=None, access_token=None):
        """Call the 'Workspace API Get Details' endpoint
        """
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", service_base_url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Workspace API Get Details] = {r.status_code} ({r.reason})")
        # process_ids = []
        # if r.status_code == 200:
        #     for process in r.json():
        #         process_ids.append(process['id'])
        return r, access_token

    #---------------------------------------------------------------------------
    # ADES WPS
    #---------------------------------------------------------------------------

    @keyword(name='WPS Get Capabilities')
    def wps_get_capabilities(self, service_base_url, id_token=None, access_token=None):
        """Call the WPS GetCapabilities endpoint
        """
        url = service_base_url + "/?service=WPS&version=1.0.0&request=GetCapabilities"
        r, access_token = self.uma_http_request("GET", url, id_token=id_token, access_token=access_token)
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
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Process List] = {r.status_code} ({r.reason})")
        process_ids = []
        if r.status_code == 200:
            for process in r.json():
                process_ids.append(process['id'])
        return r, access_token, process_ids

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
        r, access_token = self.uma_http_request("POST", url, headers=headers, id_token=id_token, access_token=access_token, json=app_deploy_body)
        print(f"[Deploy Response] = {r.status_code} ({r.reason})")
        return r, access_token

    @keyword(name='Proc App Details')
    def proc_get_app_details(self, service_base_url, app_name, id_token=None, access_token=None):
        """Get details for the application with the supplied name
        """
        url = service_base_url + "/processes/" + app_name
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[App Details] = {r.status_code} ({r.reason})")
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
        r, access_token = self.uma_http_request("POST", url, headers=headers, id_token=id_token, access_token=access_token, json=app_execute_body)
        try:
            job_location = r.headers['Location']
        except:
            job_location = None
        print(f"[Execute Response] = {r.status_code} ({r.reason}) => job={job_location}")
        return r, access_token, job_location

    @keyword(name='Proc Job Status')
    def proc_get_job_status(self, service_base_url, job_location, id_token=None, access_token=None):
        """Get the job status from the supplied location
        """
        url = service_base_url + job_location
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        if r.status_code == 200:
            response_json = r.json()
            status = response_json['status']
        else:
            status = f"Unexpected ADES response: {r.status_code}/{r.reason}"
        now = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        print(f"[Job Status] = {r.status_code} ({r.reason}) => {now} - {status} => {r.text}")
        return r, access_token, status

    @keyword(name='Proc Poll Job Completion')
    def proc_poll_job_completion(self, service_base_url, job_location, interval=30, id_token=None, access_token=None):
        """Call 'Get Job Status' in a loop until the job completes
        """
        status = "running"
        tr_before = self.trace_requests
        self.trace_requests = False
        error_count = 0
        max_error_count = 5
        while status == 'running':
            r, access_token, status = self.proc_get_job_status(service_base_url, job_location, id_token=id_token, access_token=access_token)
            # Expecting a 200 response
            if r.status_code == 200:
                error_count = 0
                if status != 'successful' and status != 'failed':
                    sleep(interval)
                else:
                    break
            # Unexpected response, latch the error
            else:
                error_count += 1
                sleep(interval)
            # Too many consecutive errors
            if error_count > max_error_count:
                print("ERROR: Too many failed attempts to get job status")
                break
        self.trace_requests = tr_before
        return r, access_token, status

    @keyword(name='Proc List Jobs')
    def proc_list_jobs(self, service_base_url, app_name, id_token=None, access_token=None):
        """Get the job status from the supplied location
        """
        url = service_base_url + "/processes/" + app_name + "/jobs"
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Job List] = {r.status_code} ({r.reason})")
        job_ids = []
        if r.status_code == 200:
            for job in r.json():
                job_ids.append(job['id'])
        return r, access_token, job_ids

    @keyword(name='Proc Job Result')
    def proc_get_job_result(self, service_base_url, job_location, id_token=None, access_token=None):
        """Get the job result from the supplied location
        """
        url = service_base_url + job_location + "/result"
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        inlineValue = r.json()['outputs'][0]['value']['inlineValue']
        stacCatalogUri = json.loads(inlineValue)['StacCatalogUri']
        print(f"[Job Result] = {r.status_code} ({r.reason}) => {stacCatalogUri}")
        return r, access_token, stacCatalogUri

    @keyword(name='Proc Undeploy App')
    def proc_undeploy_application(self, service_base_url, app_name, id_token=None, access_token=None):
        """Undeploy application via 'API Processes' endpoint
        """
        # make request
        url = service_base_url + "/processes/" + app_name
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("DELETE", url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Undeploy Response] = {r.status_code} ({r.reason})")
        return r, access_token

    @keyword(name='Update Policy')
    def update_policy(self, pdp_base_url, policy_cfg, resource_id, id_token=None, policy_id=None):
        """Updates a policy
        If a Policy_ID is passed there will only be ownership comprobation
        """
        headers = { 'content-type': "application/json", "cache-control": "no-cache", "Authorization": "Bearer "+id_token }
        res=""
        if policy_id:
            res = self.http_request("PUT", pdp_base_url + "/policy/" + policy_id, headers=headers, json=policy_cfg, verify=False)
        elif resource_id: 
            data={"resource_id": str(resource_id)}
            res = self.http_request("GET", pdp_base_url+"/policy/", headers=headers, json=data, verify=False)
            policyId= json.loads(res.text)
            for k in policyId['policies']:
                policyId = k['_id']
            res = self.http_request("PUT", pdp_base_url + "/policy/" + policyId, headers=headers, json=policy_cfg, verify=False)
        else: res = None
        if res.status_code == 401:
            return 401, res.headers["Error"]
        if res.status_code == 200:
            return 200, print(f"[Update Policy] = {res.status_code} ({res.reason})")
        return 500, print(f"[Update Policy] = {res.status_code} ({res.reason})")
    
    @keyword(name='Get Ownership Id')
    def get_ownership_id(self, id_token):
        """Get ownership id
        Returns the sub parameter from the JWT Token recibed
        """
        payload = str(id_token).split(".")[1]
        paddedPayload = payload + '=' * (4 - len(payload) % 4)
        decoded = base64.b64decode(paddedPayload)
        decoded = decoded.decode('utf-8')
        jwt_decoded = json.loads(decoded)
        return jwt_decoded["sub"]

    @keyword(name='Get Resource By Name')
    def get_resource_by_name(self, pdp_base_url, name, id_token):
        """Get Resource By Name
        Returns a resource_id matched by name
        """
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache", "Authorization": "Bearer "+id_token}
        res = requests.get( pdp_base_url +"/resources", headers=headers, verify=False)
        print(f"[URI] = {pdp_base_url}/resources")
        print(f"[Headers] = {headers}")
        print(f"[Resource by URI] = {res.status_code} ({res.reason}) -> {res.text}")
        for k in json.loads(res.text):
            if name in k['_name']:
                return k['_id']

    @keyword(name='Get Resource By URI')
    def get_resource_by_uri(self, pdp_base_url, relative_url, id_token):
        """Get Resource By Name
        Returns a resource_id matched by name
        """
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache", "Authorization": "Bearer "+id_token}
        res = requests.get( pdp_base_url +"/resources", headers=headers, verify=False)
        print(f"[URI] = {pdp_base_url}/resources")
        print(f"[Headers] = {headers}")
        print(f"[Resource by URI] = {res.status_code} ({res.reason}) -> {res.text}")
        for k in json.loads(res.text):
            if relative_url == k['_reverse_match_url']:
                return k['_id']



    @keyword(name='Clean State Resources')
    def clean_state_resources(self, pep_resource_url, id_token):
        """Clean State Resources
        Deletes from the database the list of resources matched on the state.json
        """
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache", "Authorization": "Bearer "+id_token}
        for k in self.state["resources"][pep_resource_url]:
            res = self.http_request("DELETE", pep_resource_url + "/resources/" + str(self.state["resources"][pep_resource_url][k]), headers=headers, verify=False)

    @keyword(name='Clean Owner Resources')
    def clean_owner_resources(self, pep_resource_url, id_token):
        """Clean Owner Resources
        Deletes from the database the list of resources matched by the ownership of the User identified
        """
        headers = { 'content-type': "application/x-www-form-urlencoded", "cache-control": "no-cache", "Authorization": "Bearer "+id_token}
        res = self.http_request("GET", pep_resource_url +"/resources", headers=headers, verify=False)
        for k in json.loads(res.text):
            res = self.http_request("DELETE", pep_resource_url + "/resources/" + k['_id'], headers=headers, verify=False)

    @keyword(name='Workspace Get Details')
    def workspace_get_details(self, service_base_url, workspace_name, id_token=None, access_token=None):
        """Get details for the workspace with the supplied name
        """
        url = service_base_url + "/workspaces/" + workspace_name
        headers = { "Accept": "application/json" }
        r, access_token = self.uma_http_request("GET", url, headers=headers, id_token=id_token, access_token=access_token)
        print(f"[Workspace Details] = {r.status_code} ({r.reason})")
        return r, access_token

    @keyword(name='Response Summary')
    def response_summary(self, response, isJson=True):
        print(f"STATUS = {response.status_code} {response.reason}")
        print(f"HEADERS = {response.headers}")
        if isJson:
            print(f"BODY = {json.dumps(response.json(), indent = 2)}")
        else:
            print(f"BODY = {response.text}")

    @keyword(name='Reset Resource Policy')
    def reset_resource_policy(self, resources_endpoint, pdp_endpoint, id_token, resource_name):
        """Reset Resource Policy
        Reset the resource protection policy to include only the user identified
        by the supplied token, using the supplied resource endpoint (PEP).
        The resource is identified by its URI.
        """
        owner_id = self.get_ownership_id(id_token)
        resource_id = self.get_resource_by_name(resources_endpoint, resource_name, id_token)
        #resource_id = self.get_resource_by_uri(resources_endpoint, resource_uri, id_token)
        policy = {
            "name": "Reset Policy",
            "description": "reset policy",
            "config": {
                "resource_id": resource_id,
                "action": "view",
                "rules": [
                    {
                        "EQUAL": {
                            "id": owner_id
                        }
                    }
                ]
            },
            "scopes": [
                "protected_access"
            ]
        }
        tr = self.trace_requests
        self.trace_requests = False
        self.update_policy(pdp_endpoint, policy, resource_id, id_token)
        self.trace_requests = tr
