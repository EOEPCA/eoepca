
import subprocess
import requests
import json
import os 
import sys

data2 = {}

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (str(dir_path)+"/1.txt", "r") as mytxt:
    for line in mytxt:
        d = line
adminT= json.loads(d)
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/wps3", "name":"ADES Service"}
headers = { 'content-type': "application/json", "Authorization": "Bearer "+adminT['id_token'] }
res = requests.post(sys.argv[1]+":"+ sys.argv[2] + "/resources", headers=headers, json=payload, verify=False)
#res = requests.post("http://0.0.0.0:31709/resources", headers=headers, json=payload, verify=False)

resource_id = res.text
print(resource_id)
f = open(dir_path+"/ADES.txt", "w")
f.write(resource_id)
f.close()
# Get resource
