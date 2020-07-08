import json
from json import load, dump
import time
from eoepca_scim import EOEPCA_Scim, ENDPOINT_AUTH_CLIENT_POST


def load_config(config_path: str) -> dict:
    """
    Parses and returns the config file

    Returns: dict
    """
    config = {}
    with open(config_path) as j:
        config = load(j)

    return config


def save_config(config_path: str, data: dict):
    """
    Saves updated config file
    """
    with open(config_path, 'w') as j:
        dump(data,j)

y = load_config("conf.json")

if "client_id" not in y or "client_secret" not in y:
    print ("NOTICE: Client not found, generating one... ")
    scim_client = EOEPCA_Scim(y["hostname"])
    new_client = scim_client.registerClient("UMA Flow Test Client",
                                    grantTypes = ["client_credentials", "password", "urn:ietf:params:oauth:grant-type:uma-ticket"],
                                    redirectURIs = [""],
                                    logoutURI = "", 
                                    responseTypes = ["code","token","id_token"],
                                    scopes = ['openid',  'email', 'user_name ','uma_protection', 'permission'],
                                    token_endpoint_auth_method = ENDPOINT_AUTH_CLIENT_POST)
    print("NEW CLIENT created with ID '"+new_client["client_id"]+"', since no client config was found on config.json")

    y["client_id"] = new_client["client_id"]
    y["client_secret"] = new_client["client_secret"]
    save_config("conf.json", y)
    print("New client saved to config!")
else:
    print("Client found in config, using: "+y["client_id"])
