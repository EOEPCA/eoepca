#!/usr/bin/env bash

# It depends on python3 and WellKnownHandler library!

#curl -k -v -XPOST "https://eoepca-dev.deimos-space.com/oxauth/restv1/token" -d "scope=openid&grant_type=password&username=admin&password=admin_Abcd1234#&client_id=be7d5fe9-4e60-4a84-a814-507e2568706&client_secret=a1a46378-eabc-4776-b95b-096f1dc215db"
curl -k -v -XPOST 'https://eoepca-dev.deimos-space.com/oxauth/restv1/token' -d 'scope=openid&grant_type=password&username=admin&password=admin_Abcd1234%23&client_id=be7d5fe9-4e60-4a84-a814-507e25687068&client_secret=a1a46378-eabc-4776-b95b-096f1dc215db'