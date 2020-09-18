import subprocess
import requests
import json
import os
dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/wps3/processes/eoepcaadesundeployprocess/jobs", "name":"Proc1" }
#res = requests.post("https://0.0.0.0:31707/resources/ADES", headers=headers, json=payload, verify=False)
res = requests.post("https://test.10.0.2.15.nip.io:443/secure/resources/Proc1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc1.txt", "w")
f.write('"'+resource_id+'"')
f.close()
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/wps3/processes/eo_metadata_generation_1_0/jobs", "name":"Proc1" }
#res = requests.post("https://0.0.0.0:31707/resources/ADES", headers=headers, json=payload, verify=False)
res = requests.post("https://test.10.0.2.15.nip.io:443/secure/resources/Proc1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc2.txt", "w")
f.write('"'+resource_id+'"')
f.close()