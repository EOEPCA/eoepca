import subprocess
import requests
import json
import os
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/location.txt", "r") as mytxt:
    for line in mytxt:
        data = line
with open (dir_path+"/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
JobId= data.split("nip.io",1)[1]
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":["protected_access"], "icon_uri":str(JobId), "name":"Job1" }
port="443"
https=sys.argv[1]
if not 'https' in sys.argv[1]:
    https=sys.argv[1].replace('http','https')
    print(https)
res = requests.post(https + ":"+port + "/resources/Job1", headers=headers, json=payload, verify=False)
#res = requests.post("https://0.0.0.0:31707/resources/Job1", headers=headers, json=payload, verify=False)

resource_id = res.text
f = open(dir_path+"/Job1.txt", "w")
f.write('"'+resource_id+'"')
f.close()
