
# ADES Processing

Summary description of ADES processing approach.

- [ADES Processing](#ades-processing)
  - [Application Package](#application-package)
  - [Application Deployment](#application-deployment)
  - [Application Package in Catalogue](#application-package-in-catalogue)
  - [Execute Application](#execute-application)
  - [ADES Configuration](#ades-configuration)

## Application Package

The application package is specified as a standard CWL `Workflow`...

```yaml
cwlVersion: v1.0
- class: CommandLineTool
  id: <cmd-id>
  baseCommand: <cmd>
  hints:
    DockerRequirement:
      dockerPull: <docker-image>
  etc: ...
- class: Workflow
  id: <app-id>
  inputs:
    <input-1>: ...
    etc: ...
  outputs:
    <output-1>: ...
    etc: ...
  steps:
    step_1:
      in: ...
      out: ...
      run: '#<cmd-id>'
  etc: ...
```

## Application Deployment

Application deployment is made by POST to path `/wps3/processes`.

Internally, within the ADES, the deployment is made by executing the pre-installed 'DeployProcess' process, which expects an input parameter `applicationPackage` that provides the CWL application package. The 'DeployProcess' supports the following mimeTypes for the application package payload:
* application/atom+xml - see [section Application Package in Catalogue](#application-package-in-catalogue "Application Package in Catalogue") below for an example of this encoding
* application/cwl

`POST /<user-id>/wps3/processes`

POST body in accordance with API Processes 'execute' schema...

```json
{
  "inputs": [
    {
      "id": "applicationPackage",
      "input": {
        "format": {
          "mimeType": "application/atom+xml"
        },
        "href": "https://raw.githubusercontent.com/EOEPCA/eoepca/develop/test/acceptance/02__Processing/01__ADES/data/application-package-atom.xml"
      }
    }
  ],
  "outputs": [
    {
      "format": {
        "mimeType": "string",
        "schema": "string",
        "encoding": "string"
      },
      "id": "deployResult",
      "transmissionMode": "value"
    }
  ],
  "mode": "auto",
  "response": "raw"
}
```

## Application Package in Catalogue

The application package is provided from the catalogue as an atom feed entry containing an OGC OWS Context Offering.

```xml
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <owc:offering code="http://www.opengis.net/eoc/applicationContext/cwl">
      <owc:content type="application/cwl">
```

For CWL content, see [Application Package](#application-package).

## Execute Application

POST `/<user-id>/wps3/processes/<process-id>/jobs`

POST body in accordance with API Processes 'execute' schema...

```json
{
  "inputs": [
    {
      "id": "input_reference",
      "input": {
        "format": {
          "mimeType": "application/json"
        },
        "href": "https://resource-catalogue.185.52.193.87.nip.io/?mode=opensearch&service=CSW&version=3.0.0&request=GetRecords&elementsetname=full&resulttype=results&typenames=csw:Record&recordids=S2B_MSIL2A_20200902T090559_N0214_R050_T34SFH_20200902T113910.SAFE"
      }
    },
    {
      "id": "cbn",
      "input": {
        "dataType": {
          "name": "string"
        },
        "value": "ndvi"
      }
    },
    {
      "id": "s_expression",
      "input": {
        "dataType": {
          "name": "string"
        },
        "value": "(/ (- nir red) (+ nir red))"
      }
    }
  ],
  "outputs": [
    {
      "format": {
        "mimeType": "string",
        "schema": "string",
        "encoding": "string"
      },
      "id": "wf_outputs",
      "transmissionMode": "value"
    }
  ],
  "mode": "async",
  "response": "raw"
}
```

## ADES Configuration

At deployment time the ADES is configured with CWL that defines the stage-in (`Values.stagein`) and stage-out (`Values.stageout`) functionality. In each case a CWL CommandLineTool is defined.

For example, stage-in using the `terradue/stars-t2` container...
```yaml
cwlVersion: v1.0
baseCommand: Stars
doc: "Run Stars for staging input data"
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: terradue/stars-t2:0.6.18.19
id: stars
arguments:
  - copy
  - -v
  - -rel
  - -r
  - "4"
  - -o
  - ./
  - --harvest
inputs:
  ADES_STAGEIN_AWS_SERVICEURL:
    type: string?
  ADES_STAGEIN_AWS_ACCESS_KEY_ID:
    type: string?
  ADES_STAGEIN_AWS_SECRET_ACCESS_KEY:
    type: string?
outputs: {}
requirements:
  EnvVarRequirement:
    envDef:
      PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
      AWS__ServiceURL: $(inputs.ADES_STAGEIN_AWS_SERVICEURL)
      AWS_ACCESS_KEY_ID: $(inputs.ADES_STAGEIN_AWS_ACCESS_KEY_ID)
      AWS_SECRET_ACCESS_KEY: $(inputs.ADES_STAGEIN_AWS_SECRET_ACCESS_KEY)
  ResourceRequirement: {}
```

To support this the ADES has an additional deployment configuration `Values.workflowExecutor.inputs` through which the input values to each of these CWL is passed at invocation time. For example...
```yaml
workflowExecutor:
  # Here specify fixed inputs to all workflows execution in all stages (main, stage-in/out)
  # They will be prefixed with 'ADES_'. e.g. 'APP: ades' will be 'ADES_APP: ades'
  inputs:
    APP: ades
    STAGEIN_AWS_SERVICEURL: http://data.cloudferro.com
    STAGEIN_AWS_ACCESS_KEY_ID: test
    STAGEIN_AWS_SECRET_ACCESS_KEY: test
```
...matching the inputs needed by the stage-in CWL CommandLineTool.

Thus, the ADES configuration provides an extensible apporach for specifying stage-in/out behaviour - which facilitates the integration of the ADES by a Platform Operator into their specific deployment.
