import subprocess
import requests
import json
import os 
data2 = {}
dir_path = os.path.dirname(os.path.realpath(__file__))
print(dir_path)
with open (str(dir_path)+"/../../01__UserManagement/03__PDP_Engine/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
with open (str(dir_path)+"/../../01__UserManagement/01__LoginService/1.txt", "r") as mytxt:
    for line in mytxt:
        d = line
adminT= json.loads(d)


payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES" }
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/ADES", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/ra.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/pep/ADES", "name":"ADES_RESOURCES" }
headers = { 'content-type': "application/json", "Authorization": "Bearer "+adminT['id_token'] }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/ADES_RESOURCES", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/res.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/Proc1/Deploy", "name":"Proc1" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Proc1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc1.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/Proc1/Undeploy", "name":"Proc1U" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Proc1U", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open(dir_path+"/Proc1U.txt", "w")
f.write('"'+resource_id+'"')
f.close()