import subprocess
import requests
import json
import os
dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/Job1.txt", "r") as mytxt:
    for line in mytxt:
        data = line

with open (dir_path+"/../../01__UserManagement/03__PDP_Engine/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
JobId= json.loads(data)
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/"+str(JobId), "name":"Job1" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Job1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Job1R.txt", "w")
f.write('"'+resource_id+'"')
f.close()