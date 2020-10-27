
import subprocess
import requests
import json
import os 
import sys

data2 = {}

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (str(dir_path)+"/external_id.txt", "r") as mytxt:
    for line in mytxt:
        d = line
adminT= json.loads(d)
url = sys.argv[1].replace("https", "http", 1)
payload = { "resource_scopes":[ "protected_access"], "icon_uri":"/testexternal", "name":"TestExternal" }
headers = { 'content-type': "application/json", "cache-control": "no-cache", "Authorization": "Bearer "+adminT['id_token'] }
res = requests.post(str(url)+":31707/resources/TestExternal", headers=headers, json=payload, verify=False)

resource_id = res.text
print(resource_id)
f = open(dir_path+"/res_id_ext.txt", "w+")
f.write(resource_id)
f.close()
# Get resource
