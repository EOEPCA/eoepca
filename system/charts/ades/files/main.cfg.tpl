[headers]
X-Powered-By=ZOO@ZOO-Project

[main]
version=2.0.0
encoding=utf-8
__rewriteUrl=call
dataPath=/var/www/data
tmpPath=/var/www/_run/res
sessPath=/tmp
cacheDir=/var/www/cache
lang=en-US,en-GB
language=en-US
msOgcVersion=1.0.0
tmpUrl=/res
cors=false
storeExecuteResponse=true
servicePath=/zooservices/

[identification]
title=Ellip-WPS
keywords=
abstract=
accessConstraints=none
fees=None

[provider]
positionName=xxxx
providerName=xxxx
addressAdministrativeArea=False
addressDeliveryPoint=xxxxx
addressCountry=IT
phoneVoice=+xxxxx
addressPostalCode=xxx
role=Support
providerSite=https://www.xxxxx.com
phoneFacsimile=False
addressElectronicMailAddress=support@xxxx.com
addressCity=xx
individualName=Operations Support team

[java]

[javax]

[env]

[database]

[jwt]
secret=
cert1=
cert2=

[serviceConf]
sleepGetStatus=100
sleepGetPrepare=30
sleepBeforeRes=30

[pep]
pepresource=/opt/t2service/libpep_resource.so
usepep={{ .Values.wps.usePep }}
pephost={{ .Values.wps.pepBaseUrl }}
scopes=public
pathBase=/%s/wps3/processes/%s
pathStatus=/%s/watchjob/processes/%s/jobs/%s
pathResult=/%s/watchjob/processes/%s/jobs/%s/result
stopOnError=true


[eoepca]
owsparser=/opt/t2libs/libeoepcaows.so
buildPath=/opt/t2template/

WorkflowExecutorHost=http://localhost:8000
WorkflowExecutorConfig=/opt/t2config/workflowwxecutorconfig.json
libWorkflowExecutor=/opt/t2service/libworkflow_executor.so

userworkspace=/opt/zooservices_user
defaultUser=anonymous
userSpaceScript=/opt/t2scripts/prepareUserSpace.sh
removeServiceScript=/opt/t2scripts/removeservice.sh