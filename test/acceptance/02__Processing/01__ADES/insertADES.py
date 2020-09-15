import subprocess
import requests
import json
import os
dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/02__Processing/01__ADES/1.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/ADES", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/ADES.txt", "w")
f.write('"'+resource_id+'"')
f.close()