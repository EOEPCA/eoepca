
# Processing Application

## Application Package in Catalogue

### Atom Feed

* `<entry>`
  * `<owc:offering code="http://www.opengis.net/eoc/applicationContext/cwl">`
    * `<owc:content type="application/cwl">`<br>
      See [Application Package](#application-package)

## Application Package

Standard CWL...

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

POST body...

**QUESTIONS:**
* Is this a standard format?
* How to embed the application package inline, rather than by href?

```
{
  "inputs": [
    {
      "id": "applicationPackage",
      "input": {
        "format": {
          "mimeType": "application/xml"
        },
        "value": {
          "href": "https://catalog.terradue.com/eoepca-services/search?uid=app-s-expression"
        }
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

## Execute Application

POST body...

**QUESTIONS:**
* Is this a standard format?

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

