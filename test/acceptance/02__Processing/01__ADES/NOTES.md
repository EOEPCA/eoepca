
# Notes: ADES building block testing

## Sleep between steps

It is necessary to sleep between some steps (approx. 2-3 secs) - typically the steps that change the state of the server, e.g. deploy.
It is assumed that this is needed due to the async nature of the requests.
Sleeping in tests is unreliable - so is there a better way to handle this?

e.g...
```robot
API_PROC deploy process
  API_PROC Deploy Process  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0  ${CURDIR}${/}eo_metadata_generation_1_0.json
  Sleep  3  Waiting for process deploy process to complete asynchronously
  API_PROC Is Deployed  ${ADES_BASE_URL}  ${API_PROC_PATH_PREFIX}  eo_metadata_generation_1_0
```
Must wait after the `deploy` invocation before checking the outcome, i.e. that the new process is available.

## OGC API Processes deploy/undeploy

The current implementation uses specific paths that target the underlying WPS processes for deploy/undeploy...
* deploy -> /wps3/processes/**eoepcaadesdeployprocess**/jobs
* undeploy -> /wps3/processes/**eoepcaadesundeployprocess**/jobs

It is understood that WPS standard has no transactional capability, and hence the processes `eoepcaadesdeployprocess` and `eoepcaadesundeployprocess`.
However, for OGC API Processes there is a draft extension that describes these functions:
* deploy -> POST to `/processes`
* undeploy -> DELETE to `/processes/{processId}`

(ref: https://github.com/opengeospatial/wps-rest-binding/blob/master/extensions/transactions/standard/clause_6_transactions.adoc)

Following this draft transactional extension for API Processes does not preclude using the 'special' WPS processes 'under-the-hood'.

## ADES paths /watchjob/processes/...

In its response documents the ADES returns paths prefixed with `/watchjob/processes` that seem to provide the results of the processing job. Is it correct that these are sibling to the main `/wps3/processes` path? - does the draft standard detail this, or it left to implementation?
Also, further links are provided to paths prefixed `/t2dep/processes`, that do not resolve.

