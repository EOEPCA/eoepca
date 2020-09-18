


import subprocess
import requests
import json
import os 

data2 = {}

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (str(dir_path)+"/1.txt", "r") as mytxt:
    for line in mytxt:
        d = line
adminT= json.loads(d)
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES Service"}
headers = { 'content-type': "application/json", "Authorization": "Bearer "+adminT['id_token'] }
res = requests.post("https://test.10.0.2.15.nip.io:443/secure/resources/ADES Service", headers=headers, json=payload, verify=False)
#res = requests.post("http://0.0.0.0:31707/resources/ADES", headers=headers, json=payload, verify=False)

resource_id = res.text
print(resource_id)
f = open(dir_path+"/res_id.txt", "w")
f.write(resource_id)
f.close()
# Get resource


