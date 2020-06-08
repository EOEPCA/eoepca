#!/usr/bin/env python3
from eoepca_uma import rpt, resource
from WellKnownHandler import TYPE_UMA_V2, KEY_UMA_V2_RESOURCE_REGISTRATION_ENDPOINT, KEY_UMA_V2_PERMISSION_ENDPOINT, KEY_UMA_V2_INTROSPECTION_ENDPOINT
from typing import List

class UMA_Handler:

    def __init__(self, wkhandler, oidc_handler, verify_ssl: bool = False ):
        self.wkh = wkhandler
        self.oidch = oidc_handler
        self.verify = verify_ssl

        self.update_resources_from_as()
        print("UMA Handler created, with control over "+str(len(self.registered_resources))+ " resources: "+str(self.registered_resources))

    def create(self, name: str, scopes: List[str], description: str, icon_uri: str):
        """
        Creates a new resource IF A RESOURCE WITH THAT ICON_URI DOESN'T EXIST YET.
        Will throw an exception if it exists
        """

        id, _ = self.resource_exists(icon_uri)
        if id is not None:
            raise Exception("Resource already exists for URI "+icon_uri)

        resource_registration_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_RESOURCE_REGISTRATION_ENDPOINT)
        pat = self.oidch.get_new_pat()
        new_resource_id = resource.create(pat, resource_registration_endpoint, name, scopes, description=description, icon_uri= icon_uri, secure = self.verify)
        print("Created resource '"+name+"' with ID :"+new_resource_id)

        self.add_resource_to_cache(new_resource_id)

    def validate_rpt(self, user_rpt: str, resources: List[dict], margin_time_rpt_valid: float, ) -> bool:
        """
        Returns True/False, if the RPT is valid for the resource(s) they are trying to access
        """
        introspection_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_INTROSPECTION_ENDPOINT)
        pat = self.oidch.get_new_pat()
        return rpt.is_valid_now(user_rpt, pat, introspection_endpoint, resources, time_margin= margin_time_rpt_valid ,secure= self.verify )

    def add_resource_to_cache(self, id: str):
        """
        Adds a resource's if to internal cache
        """
        self.registered_resources.append(id)

    def update_resources_from_as(self):
        """
        Updates the cache of resources
        """
        # Get a list of the controlled resources
        pat = self.oidch.get_new_pat()
        resource_reg_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_RESOURCE_REGISTRATION_ENDPOINT)
        self.registered_resources = resource.list(pat, resource_reg_endpoint, self.verify)

    def resource_exists(self, icon_uri: str) -> (str, str):
        """
        Checks if the resources managed already contain a resource with that URI.

        Returns the matching (resource_id, scopes) or None if not found
        """
        self.update_resources_from_as()
        pat = self.oidch.get_new_pat()
        resource_reg_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_RESOURCE_REGISTRATION_ENDPOINT)
        for r in self.registered_resources:
            data = resource.read(pat, resource_reg_endpoint, r, self.verify)
            if "icon_uri" in data and data["icon_uri"] == icon_uri:
                return data["_id"], data["resource_scopes"]
        
        return None, None
       
    def request_access_ticket(self, resources):
        permission_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_PERMISSION_ENDPOINT)
        pat = self.oidch.get_new_pat()
        return resource.request_access_ticket(pat, permission_endpoint, resources, secure = self.verify)

    def status(self):
        """
        Demo/debug-oriented function, to display the information of all controlled resources
        """
        pat = self.oidch.get_new_pat()
        resource_reg_endpoint = self.wkh.get(TYPE_UMA_V2, KEY_UMA_V2_RESOURCE_REGISTRATION_ENDPOINT)
        actual_resources = resource.list(pat, resource_reg_endpoint, self.verify)

        print("-----------STATUS-----------")
        print(str(len(self.registered_resources))+" Locally cached resources, with IDS: "+str(self.registered_resources))
        print(str(len(actual_resources))+ " Actual Resources registered in the AS, with IDS: "+str(actual_resources))
        print("-----------LIVE INFORMATION FROM AS------")
        for r in actual_resources:
            info = resource.read(pat, resource_reg_endpoint, r, secure= self.verify)
            print(info)
            print("++++++++++++++++")
        print("-----------STATUS END-------")
