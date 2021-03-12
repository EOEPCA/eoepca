
# Processing Application

## Application Package

The application package is specified as a standard CWL `Workflow`...

```
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

An application is deployed by executing (API Processes) the pre-installed 'DeployProcess' process, which expects an input parameter `applicationPackage` that provides the CWL application package. The 'DeployProcess' supports the following mimeTypes for the application package payload:
* application/atom+xml - see [section Application Package in Catalogue](#application-package-in-catalogue "Application Package in Catalogue") below for an example of this encoding
* application/cwl

`POST /<user-id>/wps3/processes/DeployProcess`

POST body in accordance with API Processes 'execute' schema...

```
{
  "inputs": [
    {
      "id": "applicationPackage",
      "input": {
        "format": {
          "mimeType": "application/xml"
        },
        "href": "https://catalog.terradue.com/eoepca-services/search?uid=app-s-expression"
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

```
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

