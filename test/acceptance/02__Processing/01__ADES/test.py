import subprocess
import requests
import json
data2 = {}

with open ("/home/vagrant/eoepca/test/acceptance/01__UserManagement/03__PDP_Engine/2.txt", "r") as mytxt:
    for line in mytxt:
        data2 = line
res= json.loads(data2)
with open ("/home/vagrant/eoepca/test/acceptance/02__Processing/01__ADES/Job1.txt", "r") as mytxt:
    for line in mytxt:
        data = line
job_id= json.loads(data2)
payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/", "name":"ADES" }
headers = { 'content-type': "application/json", "Authorization": "Bearer "+res['id_token'] }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/ADES", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open("/home/vagrant/eoepca/test/acceptance/02__Processing/01__ADES/res.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/Proc1/Deploy", "name":"Proc1" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Proc1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open("/home/vagrant/eoepca/test/acceptance/02__Processing/01__ADES/Proc1.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/Proc1/Undeploy", "name":"Proc1U" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Proc1U", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open("/home/vagrant/eoepca/test/acceptance/02__Processing/01__ADES/Proc1U.txt", "w")
f.write('"'+resource_id+'"')
f.close()

payload = { "resource_scopes":[ "Authenticated"], "icon_uri":"/Job1", "name":"Job1" }
res = requests.post("https://test.10.0.2.15.nip.io:443/pep/resources/Job1", headers=headers, json=payload, verify=False)
resource_id = res.text
f = open("/home/vagrant/eoepca/test/acceptance/02__Processing/01__ADES/Job1R.txt", "w")
f.write('"'+resource_id+'"')
f.close()