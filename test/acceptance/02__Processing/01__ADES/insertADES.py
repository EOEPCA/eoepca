import subprocess
import requests
import json
import os
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/1.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/ades", "name":"ADES" }
#res = requests.post("https://0.0.0.0:31707/resources/ADES", headers=headers, json=payload, verify=False)
res = requests.post(sys.argv[1] + "/resources/ADES", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/ADES.txt", "w")
f.write('"'+resource_id+'"')
f.close()
