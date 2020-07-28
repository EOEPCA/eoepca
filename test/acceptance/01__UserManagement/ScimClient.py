from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST

class ScimClient:
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '0.1'

    def __init__(self, hostname):
        self.hostname = hostname
        self.details = None
    
    def scim_client_get_details(self):
        if self.details == None:
            print("Registering new client")
            scim_client = EOEPCA_Scim(self.hostname)
            self.client = scim_client.registerClient(
                "UMA Flow Test Client",
                grantTypes = ["client_credentials", "password", "urn:ietf:params:oauth:grant-type:uma-ticket"],
                redirectURIs = [""],
                logoutURI = "",
                responseTypes = ["code","token","id_token"],
                scopes = ['openid',  'email', 'user_name ','uma_protection', 'permission'],
                token_endpoint_auth_method = ENDPOINT_AUTH_CLIENT_POST)
            self.details = {}
            self.details["client_id"] = self.client["client_id"]
            self.details["client_secret"] = self.client["client_secret"]
        else:
            print("Reusing existing client")
        return self.details
