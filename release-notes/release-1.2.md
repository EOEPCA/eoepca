# EOEPCA System - Release 1.2

Release 1.2 includes versions of the following building blocks...

| Component | Chart | Application |
| --- | :---: | :---: |
| Login Service | `1.2.1` | `v1.1.2` |
| User Profile | `1.1.6` | `v1.1` |
| Resource Guard<br>-> PEP (Policy Enforcement Point)<br>-> UMA User Agent | `1.2.0`<br>`1.1.5`<br>`1.2.0` | `u1.2.0:p1.1.5`<br>`v1.1`<br>`v1.2.0` |
| PDP (Policy Decision Point) | `1.1.6` | `v1.1` |
| ADES (Application Deployment & Execution Service) | `2.0.4` | `2.0.8` |
| PDE (Processor Development Environment) | `1.1.12` | `2.0.2` |
| Resource Catalogue | `1.2.0` | `3.0.0` |
| Data Access | `1.2.5` | `2.2.8` |
| Workspace | `1.2.0` | `1.2.0` |

See the [Release v1.2 Description](https://github.com/EOEPCA/eoepca/blob/v1.2/release-notes/release-description/release-description.adoc "Release v1.2 Description") for more details.

## Changes Since v1.1

The release includes bugfixes to the v1.1 building blocks, plus the following main enhancements...

| Component | Feature |
| --- | --- |
| ADES | ades v2 aligned to OGC API Processes 1.0 standard |
| ADES | improved documentation for stage-in/out - see https://github.com/EOEPCA/proc-ades/wiki/Stagein%20Stageout%20Interfaces |
| ADES | improvements to execution error reporting |
| ADES | support for CWL parsing of multi-type inputs |
| ADES | fix for 'too long' workflow ID |
| ADES | fix for undeploy |
| ADES | fix stage-in from S3 |
| ADES | fix stage-out to workspace |
| Resource Catalogue | support for Application Packages (of type `application`), in accordance with the OGC Best Practise for APs |
| Resource Catalogue | registration of Collections as resources |
| Resource Catalogue | registration of ADES instances as resources (of type `service`) |
| Resource Catalogue | improvements to resultset ATOM representation |
| Data Access | improvements to the `renderer` for performance and resilience |
| Data Access | performance improvements to the View Server web client |
| Data Access | add `seeder` service for cache pre-population |
| Data Access | fix registration of processing results to user workspace |
| Data Access | fix WCS rendering |
| "Data Holding" | support for Landsat-8 data harvested from CREODIAS |
| Workspace API | use of templates to reduce sub-chart dependencies |
| Workspace API | remove `flux` pre-requisite |
| Workspace API | registration of Application Packages, Collections and ADES |
| Login Service | add Registration page |
| Login Service | support for integration of customised GUI look-and-feel |
| Login Service | support for custom-specified Kubernetes namespace |
| PDP | support for custom-specified Kubernetes namespace |
| PDP | support for TLS endpoint protection |
| User Profile | support for custom-specified Kubernetes namespace |
| User Profile | support for TLS endpoint protection |

> NOTE that this release includes major release 2.0 of the ADES. Significantly, ADES 2.0 has an updated REST interface that now conforms to the OGC API Processes 1.0 standard - whereas the ADES 1.0 implemented a draft of this standard from OGC Testbed-14. See the ADES wiki pages for [**deploy**](https://github.com/EOEPCA/proc-ades/wiki/Deploy%20an%20application) and [**execute**](https://github.com/EOEPCA/proc-ades/wiki/Submit%20a%20processing%20job) to understand the differences.

## Known Issues

The following issues are known to affect the `v1.2` release.

* None

## Release 1.2 Scope

The release demonstrates the following capabilities:
* User authentication:
  * Login with GitHub
  * Login with ESA Commercial Operator Identity Hub (COIH)
  * Login with username/password
* Client Registration
  * Dynamic client registration via SCIM endpoint<br>
* Authorisation
  * Dynamic Resource Registration<br>
    *Resource servers dynamic registration of resources*
  * Resource protection<br>
    *Enforcing a policy in which resources are owned and protected accordingly*
  * Policy-based resource protection<br>
    *Enforcing policy based upon policy rules maintained in the PDP*
* Processing Capabilities (ADES resource server)
  * OGC API Processes 1.0
  * OGC WPS 2.0
  * Secure protected resource server, with access policy enforcement via PEP
  * List available processes
  * Deploy process (docker container with CWL application package)
  * Execute process (create job)
  * Get job status
  * Data stage-in via STAC/OpenSearch catalogue reference
  * Data stage-out to S3 bucket
  * Undeploy process
  * Integration of Calrissian CWL Workflow engine<br>
    *Provides native Kubernetes integration and out-of-the-box support for a variety of execution patterns - such fan-in, fan-out, etc.*
  * Dedicated user 'context' within ADES service
* Processor Development Environment (PDE)
  * JupyterHub for multi-user sessions
  * JupyterHub integrated with Login Service for user authentication
  * JupyterLab for user PDE instance
  * Jupyter Notebooks for interactive analysis
  * Theia IDE to develop using an integrated development environment
  * Tools for application package testing
* Resource Catalogue
  * Implements ISO Metadata Application Profile 1.0.0
  * Support for ISO-19115-1 and ISO-19115-2
  * OGC CSW 3.0.0 and 2.0.2 interfaces
    * Certified OGC Compliant and OGC Reference Implementation for both CSW 2.0.2 and CSW 3.0.0
    * Harvesting support for WMS, WFS, WCS, WPS, WAF, CSW, SOS
    * Federated catalogue distributed searching
  * OGC API Records
  * SpatioTemporal Asset Catalog (STAC) 1.0.0-rc1
  * OpenSearch
    * OGC OpenSearch Geo and Time Extensions
    * OGC OpenSearch EO Extensions
* Data Access Service
  * OGC WMS 1.1 - 1.3 interfaces
  * OGC WMTS 1.0 interfaces with automatic caching
  * OGC WCS 2.0 interfaces with EO Application Profile
  * OGC OpenSearch with EO, Geo and Time Extensions
  * Workspace management API
  * Dataset registration API
  * Registration schemes for Sentinel-2 L1C/L2A data in Data Access Service and Ressource Catalogue
* Data Harvesting
  * Population of resource catalogue and data-access services from external data offerings
  * Sources supported include: file-system, search service (e.g. OpenSearch), catalog file
  * Filters, e.g. time, bbox, collection
  * Post-processing to adjust harvested results, e.g. for completion of missing metadata
  * Harvested results are transformed to STAC items for registration
* End-to-end Processing Execution
  * Authenticated user accessing protected ADES endpoints
  * Dynamic creation of ADES user context with dynamic resource protection
  * Processing inputs discovered in Resource Catalogue
  * Processing inputs accessed via S3 (e.g. CREODIAS eodata)
  * Processing stage-in using STAC file to describe inputs
  * Processing execution on ADES
  * Processing stage-in using STAC file to describe inputs
  * Processing stage-out to S3 bucket
  * Processing stage-out using STAC file to describe outputs
  * Secure interfacing between ADES and user's protected Workspace<br>
    ADES client -> Get Workspace Details / (De-)Register Resources
* User Workspace
  * Secure protection of user-owned resources, with access policy enforcement via PEP
    * User-specific S3 bucket for resource storage
    * User-specific Resource Catalogue
    * User-specific Data Access Services
  * Secure protected management interface (workspace-api), with access policy enforcement via PEP
  * Management functions via REST API...
    * Create workspace (admin)
    * Get workspace details (user)
    * Delete workspace (admin)
    * Patch workspace (admin)
    * Redeploy workspace (admin)
    * Register resources (user)
    * Deregister resources (user)
* Sample application: s-expression for EO product band math<br>
  Three application packages based-upon s-expression:
  * App s-expression
  * App Water Mask
  * App NVDI
* Sample application: Normalized Hotspot Indices


## Building Blocks

This section identifies the version of the building blocks components comprising this release, and provides links for further information. For each, in this repository, we include an 'Example' deployment configuration using a flux HelmRelease resource - these must be adapted for individual deployments.

Alternatvely, for deployment advice, see the [Deployment Guide](https://deployment-guide.docs.eoepca.org/v1.2/) which provides full system deployment descriptions, examples and supporting scripts.

## User Management

### Login Service

* Version: v1.1.2
* Chart version: 1.2.1
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/login-service-1.2.1/charts/login-service
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/user-management/um-login-service.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-login-service
* README: https://github.com/EOEPCA/um-login-service/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-login-service/wiki
* Design: https://eoepca.github.io/um-login-service/SDD/v0.3/
* ICD: https://eoepca.github.io/um-login-service/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/login-service/

#### Containers

* **um-login-passport (version v1.0.0)**
  * Image: eoepca/um-login-passport:v1.0.0
  * GitHub: https://github.com/EOEPCA/um-login-passport
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-passport

* **um-login-persistence (version v1.1)**
  * Image: eoepca/um-login-persistence:v1.1
  * GitHub: https://github.com/EOEPCA/um-login-persistence
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-persistence

Additional container images:
* Gluu Server:
  * gluufederation/config-init:4.1.1_02
  * gluufederation/oxauth:4.1.1_03
  * gluufederation/oxtrust:4.1.1_02
  * gluufederation/wrends:4.1.1_01


### Resource Guard

The Resource Guard acts as an umbrella for the protection of resource servers via the `pep-engine` (Policy Enforcement Point) and `uma-user-agent` (UMA User Agent) components.

Resource Guard:
* Version: u1.2.0:p1.1.5
* Chart version: 1.2.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/resource-guard-1.2.0/charts/resource-guard
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml
* README: https://github.com/EOEPCA/helm-charts/blob/resource-guard-1.2.0/charts/resource-guard/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/resource-protection/

#### Policy Enforcement Point (PEP)

* Version: v1.1
* Chart version: 1.1.5
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/pep-engine-1.1.5/charts/pep-engine
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml#L28

##### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pep-engine
* README: https://github.com/EOEPCA/um-pep-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pep-engine/wiki
* Design: https://eoepca.github.io/um-pep-engine/SDD/v0.3/
* ICD: https://eoepca.github.io/um-pep-engine/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/resource-protection/

##### Containers

* **um-pep-engine (version v1.1)**
  * Image: eoepca/um-pep-engine:v1.1
  * GitHub: https://github.com/EOEPCA/um-pep-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pep-engine

Additional container images:
* mongo (latest)

#### UMA User Agent

* Version: v1.2.0
* Chart version: 1.2.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/uma-user-agent-1.2.0/charts/uma-user-agent
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml#L59

##### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/uma-user-agent
* README: https://github.com/EOEPCA/uma-user-agent/blob/develop/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/resource-protection/

##### Containers

* **uma-user-agent (version v1.2.0)**
  * Image: eoepca/uma-user-agent:v1.2.0
  * GitHub: https://github.com/EOEPCA/uma-user-agent
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/uma-user-agent


### Policy Decision Point (PDP)

* Version: v1.1
* Chart version: 1.1.6
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/pdp-engine-1.1.6/charts/pdp-engine
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/user-management/um-pdp-engine.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pdp-engine
* README: https://github.com/EOEPCA/um-pdp-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pdp-engine/wiki
* Design: https://eoepca.github.io/um-pdp-engine/SDD/v0.3/
* ICD: https://eoepca.github.io/um-pdp-engine/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/pdp/

#### Containers

* **um-pdp-engine (version v1.1)**
  * Image: eoepca/um-pdp-engine:v1.1
  * GitHub: https://github.com/EOEPCA/um-pdp-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pdp-engine

Additional container images:
* mongo (latest)


### User Profile

* Version: v1.1
* Chart version: 1.1.6
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/user-profile-1.1.6/charts/user-profile
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/user-management/um-user-profile.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-user-profile
* README: https://github.com/EOEPCA/um-user-profile/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-user-profile/wiki
* Design: https://eoepca.github.io/um-user-profile/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/user-profile/

#### Containers

* **um-user-profile (version 1.1)**
  * Image: eoepca/um-user-profile:v1.1
  * GitHub: https://github.com/EOEPCA/um-user-profile
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-user-profile


## Processing and Chaining

### ADES

* Version: 2.0.8
* Chart version: 2.0.4
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/ades-2.0.4/charts/ades
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/processing-and-chaining/proc-ades.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/proc-ades
* README: https://github.com/EOEPCA/proc-ades/blob/master/README.md
* Wiki: https://github.com/EOEPCA/proc-ades/wiki
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/ades/

#### Containers

* **proc-ades (version 2.0.8)**
  * Image: eoepca/proc-ades:2.0.8
  * GitHub: https://github.com/EOEPCA/proc-ades
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/proc-ades

Additional container images:
* Stage-in: terradue/stars:2.9.2
* Stage-out: terradue/stars:1.0.0-beta.11


### Processor Development Environment (PDE)

* Version: 2.0.2
* Chart version: 1.1.12
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/pde-jupyterhub-1.1.12/charts/pde-jupyterhub
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/processing-and-chaining/pde-hub._yaml

#### Containers

* **pde-container (version 1.0.3)**
  * Image: eoepca/pde-container:1.0.3
  * GitHub: https://github.com/EOEPCA/pde-container
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/pde-container

* **jupyterhub/k8s-hub (version 1.1.2)**
  * Image: jupyterhub/k8s-hub:1.1.2


### Sample Applications

Sample application packages for deployment and execution on the ADES:
* s-expression: https://github.com/EOEPCA/app-s-expression/blob/main/README.md
* Normalized Hotspot Indices (nhi): https://github.com/EOEPCA/app-nhi/blob/develop/README.md
* snuggs: https://github.com/EOEPCA/app-snuggs/blob/main/README.md


## Resource Management

### Resource Catalogue

* Version: 3.0.0
* Chart version: 1.2.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/rm-resource-catalogue-1.2.0/charts/rm-resource-catalogue
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/resource-management/hr-resource-catalogue.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/geopython/pycsw
* README: https://pycsw.org/
* Wiki: https://docs.pycsw.org/en/latest/
* Design: https://eoepca.github.io/rm-resource-catalogue/SDD/
* ICD: https://eoepca.github.io/rm-resource-catalogue/ICD/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/resource-catalogue/

#### Containers

* **pycsw (version eoepca-1.2.0)**
  * Image: geopython/pycsw:eoepca-1.2.0

Additional container images:
* Database: postgis/postgis:12-3.1


### Data Access Services

* Version: 2.2.8
* Chart version: 1.2.5
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/data-access-1.2.5/charts/data-access
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/resource-management/hr-data-access.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-data-access/
* README: https://github.com/EOEPCA/rm-data-access/blob/master/README.md
* Wiki: https://github.com/EOEPCA/rm-data-access/wiki
* Design: https://eoepca.github.io/rm-data-access/SDD/
* ICD: https://eoepca.github.io/rm-data-access/ICD/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/data-access/

#### Containers

* **rm-data-access-core (version 1.2.5)**
  * Image: eoepca/rm-data-access-core:1.2.5
  * GitHub: https://github.com/EOEPCA/rm-data-access
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-data-access-core

* **rm-harvester (version 1.2.0)**
  * Image: eoepca/rm-harvester:1.2.0
  * GitHub: https://github.com/EOEPCA/rm-harvester
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-harvester

Additional container images:
* Cache: registry.gitlab.eox.at/vs/cache:release-2.0.24
* Client: registry.gitlab.eox.at/vs/client:release-2.0.33
* Database: bitnami/postgresql:11.13.0-debian-10-r40
* Redis: bitnami/redis:6.0.8-debian-10-r0
* Scheduler: registry.gitlab.eox.at/vs/scheduler:release-2.0.2
* Seeder: registry.gitlab.eox.at/vs/cache/seeder:release-2.0.24


### Workspace

* Version: 1.2.0
* Chart version: 1.2.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/rm-workspace-api-1.2.0/charts/rm-workspace-api/
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/resource-management/hr-workspace-api.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-workspace-api/
* README: https://github.com/EOEPCA/rm-workspace-api/blob/master/README.md
* Wiki: https://github.com/EOEPCA/rm-workspace-api/wiki
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/workspace/#workspace-api

#### Containers

* **rm-workspace-api (version 1.2.0)**
  * Image: eoepca/rm-workspace-api:1.2.0
  * GitHub: https://github.com/EOEPCA/rm-workspace-api
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-workspace-api


### Bucket Operator

* Version: 1.1.0
* Chart version: 0.9.9
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/rm-bucket-operator-0.9.9/charts/rm-bucket-operator/
* Example: https://github.com/EOEPCA/eoepca/blob/v1.2/system/clusters/creodias/resource-management/bucket-operator/hr-bucket-operator.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-bucket-operator/
* README: https://github.com/EOEPCA/rm-bucket-operator/blob/master/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/v1.2/eoepca/workspace/#bucket-operator

#### Containers

* **bucket-operator (version 1.1.0)**
  * Image: eoepca/rm-bucket-operator:1.1.0
  * GitHub: https://github.com/EOEPCA/rm-bucket-operator/
