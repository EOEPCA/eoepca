import subprocess
import requests
import json
import os
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))
with open (dir_path+"/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)

headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
payload = { "resource_scopes":[ "protected_access"], "icon_uri":"/wps3/processes/eoepcaadesundeployprocess/jobs", "name":"Proc1" }
res = requests.post(sys.argv[1] + ":"+sys.argv[2]+ "/resources", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc1.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "protected_access"], "icon_uri":"/wps3/processes/app_deploy_body/jobs", "name":"Proc1" }
res = requests.post(sys.argv[1] + ":"+sys.argv[2]+ "/resources", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc2.txt", "w")
f.write('"'+resource_id+'"')
f.close()