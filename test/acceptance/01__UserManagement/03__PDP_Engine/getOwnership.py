import base64
import json
import os 
import sys

dir_path = os.path.dirname(os.path.realpath(__file__))

payload = str(sys.argv[1]).split(".")[1]
paddedPayload = payload + '=' * (4 - len(payload) % 4)
decoded = base64.b64decode(paddedPayload)
decoded = decoded.decode('utf-8')
jwt_decoded = json.loads(decoded)
f = open(dir_path+"/ownership_id.txt", "w")
f.write(jwt_decoded["sub"])
f.close()