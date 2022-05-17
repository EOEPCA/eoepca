# EOEPCA System - Release 1.1

Release 1.1 is mostly a bugfix release, with some limited feature enhancements to 1.0.

Release 1.1 includes versions of the following building blocks:
* Login Service
* User Profile
* Policy Enforcement Point (PEP)
* Policy Decision Point (PDP)
* Application Deployment & Execution Service (ADES)
* Processor Development Environment (PDE)
* Resource Catalogue
* Data Access Services
* Workspace

See the [Release v1.1 Description](https://github.com/EOEPCA/eoepca/blob/v1.1/release-notes/release-description/release-description.adoc "Release v1.1 Description") for more details.

## Changes Since v1.0

### Summary of Fixes

TBD...

* Resource Catalogue: database deployment switched to stateful set
* Resource Catalogue: OpenSearch EO parameter detection fix
* Resource Catalogue: OGC API Records: change items startindex to offset
* Resource Catalogue: fixed compatibility with latest Werkzeug version
* Processing and Chaining: nodeselector fix for processing pods
* Processing and Chaining: k8s role creation fix for processing job namespaces
* Policy Decision Point (PDP): fixed default authenticated validation for policies
* add your fixes here
* ...

### New Features

TBD...

* Resource Catalogue implements OGC API Records virtual collections (pycsw RFC 10)
* Resource Catalogue compatible with STAC API 1.0.0-rc1
* Resource Catalogue supports custom database mappings
* Resource Catalogue a Reference Implementation of OGC GeoRSS 1.0
* Resource Catalogue: update based on latest CQL2 models
* Resource Catalogue: Support for Kubernetes 2.22 ingress
* Processing and Chaining: support for sub-workflows in application packages
* Processing and Chaining: support for application packages with multiple workflows
* Processing and Chaining: support for k8s version 1.22.x
* Processing and Chaining: optimized method to parse the processing results
* Policy Decision Point (PDP): validation option based on Terms and Conditions
* Policy Decision Point (PDP): endpoint for managing Terms and Conditions
* Policy Enforcement Point (PEP): option for retrieving resource information by providing the protected URI
* Login Service: support for OSC role attributes

* add your new features here
* ...

## Release 1.0 Scope

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
  * OGC WPS 2.0 and OGC API Processes interfaces
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
* Processor Development Environment
  * JupyterLab interface to interact with code and data
  * Theia IDE to develop using an integrated development environment
  * Local S3 Object Storage with MinIO to store EO data and results
  * Jenkins instance to build the code with Continuous Integration
  * Docker-in-Docker (with an Ubuntu host)
  * Tools for application package testing
* Resource Catalogue
  * Implements ISO Metadata Application Profile 1.0.0
  * Support for ISO-19115-1 and ISO-19115-2
  * OGC CSW 3.0.0 and 2.0.2 interfaces
    * Certified OGC Compliant and OGC Reference Implementation for both CSW 2.0.2 and CSW 3.0.0
    * Harvesting support for WMS, WFS, WCS, WPS, WAF, CSW, SOS
    * Federated catalogue distributed searching
  * OGC API Records
  * STAC (SpatioTemporal Asset Catalog)
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

This section identifies the version of the building blocks components comprising this release, and provides links for further information. For each, we include an 'Example' deployment configuration using a flux HelmRelease resource - these must be adapted for individual deployments.

Alternatvely, for deployment advice, see the [Deployment Guide](https://deployment-guide.docs.eoepca.org/) which provides full system deployment descriptions, examples and supporting scripts.

## User Management

### Login Service

* Version: v1.1.2
* Chart version: 1.1.4
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/login-service-1.1.4/charts/login-service
* Example: https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/user-management/um-login-service.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-login-service
* README: https://github.com/EOEPCA/um-login-service/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-login-service/wiki
* Design: https://eoepca.github.io/um-login-service/SDD/v0.3/
* ICD: https://eoepca.github.io/um-login-service/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/login-service/

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
* Version: 1.0.0
* Chart version: 1.0.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/resource-guard-1.0.0/charts/resource-guard
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml
* README: https://github.com/EOEPCA/helm-charts/blob/resource-guard-1.0.0/charts/resource-guard/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/resource-protection/

#### Policy Enforcement Point (PEP)

* Version: v1.1.1
* Chart version: 1.1.2
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/pep-engine-1.1.2/charts/pep-engine
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml#L29

##### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pep-engine
* README: https://github.com/EOEPCA/um-pep-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pep-engine/wiki
* Design: https://eoepca.github.io/um-pep-engine/SDD/v0.3/
* ICD: https://eoepca.github.io/um-pep-engine/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/resource-protection/

##### Containers

* **um-pep-engine (version v1.1)**
  * Image: eoepca/um-pep-engine:v1.1
  * GitHub: https://github.com/EOEPCA/um-pep-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pep-engine

Additional container images:
* mongo (latest)

#### UMA User Agent

* Version: 1.0.0
* Chart version: 1.0.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/uma-user-agent-1.0.0/charts/uma-user-agent
* Example (ADES Protection): https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/processing-and-chaining/proc-ades-guard.yaml#L60

##### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/uma-user-agent
* README: https://github.com/EOEPCA/uma-user-agent/blob/develop/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/resource-protection/

##### Containers

* **uma-user-agent (version 1.0.0)**
  * Image: eoepca/uma-user-agent:1.0.0
  * GitHub: https://github.com/EOEPCA/uma-user-agent
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/uma-user-agent


### Policy Decision Point (PDP)

* Version: v1.1.1
* Chart version: 1.1.2
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/pdp-engine-1.1.2/charts/pdp-engine
* Example: https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/user-management/um-pdp-engine.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pdp-engine
* README: https://github.com/EOEPCA/um-pdp-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pdp-engine/wiki
* Design: https://eoepca.github.io/um-pdp-engine/SDD/v0.3/
* ICD: https://eoepca.github.io/um-pdp-engine/ICD/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/pdp/

#### Containers

* **um-pdp-engine (version v1.1)**
  * Image: eoepca/um-pdp-engine:v1.1
  * GitHub: https://github.com/EOEPCA/um-pdp-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pdp-engine

Additional container images:
* mongo (latest)


### User Profile

* Version: v1.1.1
* Chart version: 1.1.2
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/user-profile-1.1.2/charts/user-profile
* Example: https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/user-management/um-user-profile.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-user-profile
* README: https://github.com/EOEPCA/um-user-profile/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-user-profile/wiki
* Design: https://eoepca.github.io/um-user-profile/v0.3/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/user-profile/

#### Containers

* **um-user-profile (version 1.1)**
  * Image: eoepca/um-user-profile:v1.1
  * GitHub: https://github.com/EOEPCA/um-user-profile
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-user-profile


## Processing and Chaining

### ADES

* Version: 1.0.0
* Chart version: 1.0.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/ades-1.0.0/charts/ades
* Example: https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/processing-and-chaining/proc-ades.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/proc-ades
* README: https://github.com/EOEPCA/proc-ades/blob/master/README.md
* Wiki: https://github.com/EOEPCA/proc-ades/wiki
* Deployment Guide: https://deployment-guide.docs.eoepca.org/ades/

#### Containers

* **proc-ades (version 1.0.0)**
  * Image: eoepca/proc-ades:1.0.0
  * GitHub: https://github.com/EOEPCA/proc-ades
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/proc-ades

Additional container images:
* Stage-in: terradue/stars:1.0.0-beta.11
* Stage-out: terradue/stars:1.0.0-beta.11


### Processor Development Environment (PDE)

The initial version of the PDE, that is included in eoepca-v1.0, is engineered as a virtual machine that can be instantiated locally or within a cloud environment. This VM-based approached to the PDE is being deprecated in favour of a 'cloud-native' approach in which the PDE will be fully containerised for Kubernetes deployment. The cloud-native PDE will be released in a later version of the EOEPCA system.

* Version: 0.3
* README: https://github.com/EOEPCA/proc-pde/blob/0.3/README.md


### Sample Applications

Sample application packages for deployment and execution on the ADES:
* s-expression: https://github.com/EOEPCA/app-s-expression/blob/main/README.md
* Normalized Hotspot Indices (nhi): https://github.com/EOEPCA/app-nhi/blob/develop/README.md
* snuggs: https://github.com/EOEPCA/app-snuggs/blob/main/README.md


## Resource Management

### Resource Catalogue

* Version: 3.0.0
* Chart version: 1.1.0
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/rm-resource-catalogue-1.1.0/charts/rm-resource-catalogue
* Example: https://github.com/EOEPCA/eoepca/blob/v1.0/system/clusters/creodias/resource-management/hr-resource-catalogue.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/geopython/pycsw
* README: https://pycsw.org/
* Wiki: https://docs.pycsw.org/en/latest/
* Design: https://eoepca.github.io/rm-resource-catalogue/SDD/
* ICD: https://eoepca.github.io/rm-resource-catalogue/ICD/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/resource-catalogue/

#### Containers

* **pycsw (version 1.1.0)**
  * Image: geopython/pycsw:eoepca-1.1.0

Additional container images:
* Database: postgis/postgis:12-3.1


### Data Access Services

* Version: 2.1.4
* Chart version: 2.1.4
* Helm chart: https://gitlab.eox.at/esa/prism/vs/
* Example: https://github.com/EOEPCA/eoepca/blob/v1.1/system/clusters/creodias/resource-management/hr-data-access.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-data-access/
* README: https://github.com/EOEPCA/rm-data-access/blob/master/README.md
* Wiki: https://github.com/EOEPCA/rm-data-access/wiki
* Design: https://eoepca.github.io/rm-data-access/SDD/
* ICD: https://eoepca.github.io/rm-data-access/ICD/
* Deployment Guide: https://deployment-guide.docs.eoepca.org/data-access/

#### Containers

* **rm-data-access-core (version 1.1.0)**
  * Image: eoepca/rm-data-access-core:1.1.0
  * GitHub: https://github.com/EOEPCA/rm-data-access
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-data-access-core

* **rm-harvester (version 1.1.0)**
  * Image: eoepca/rm-harvester:1.1.0
  * GitHub: https://github.com/EOEPCA/rm-harvester
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-harvester

Additional container images:
* Cache: registry.gitlab.eox.at/vs/cache:release-2.0.9
* Client: registry.gitlab.eox.at/vs/client:release-2.0.18
* Database: bitnami/postgresql:11.13.0-debian-10-r40
* Redis: bitnami/redis:6.0.8-debian-10-r0
* Scheduler: registry.gitlab.eox.at/vs/scheduler:release-2.0.0


### Workspace

* Version: 1.1.1
* Chart version: 1.1.1
* Helm chart: https://github.com/EOEPCA/helm-charts/tree/rm-workspace-api-1.1.1/charts/rm-workspace-api/
* Example: https://github.com/EOEPCA/eoepca/blob/v1.1/system/clusters/creodias/resource-management/hr-workspace-api.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-workspace-api/
* README: https://github.com/EOEPCA/rm-workspace-api/blob/master/README.md
* Wiki: https://github.com/EOEPCA/rm-workspace-api/wiki
* Deployment Guide: https://deployment-guide.docs.eoepca.org/workspace/#workspace-api

#### Containers

* **rm-workspace-api (version 1.1.2)**
  * Image: eoepca/rm-workspace-api:1.1.2
  * GitHub: https://github.com/EOEPCA/rm-workspace-api
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-workspace-api


### Bucket Operator

* Version: 0.9.9
* No helm chart (coming soon) - installed directly with k8s yaml
* Kubernetes yaml: https://github.com/EOEPCA/eoepca/tree/v1.1/system/clusters/creodias/resource-management/bucket-operator/

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/rm-bucket-operator/
* README: https://github.com/EOEPCA/rm-bucket-operator/blob/master/README.md
* Deployment Guide: https://deployment-guide.docs.eoepca.org/workspace/#bucket-operator

#### Containers

* **bucket-operator (version 1.1.0)**
  * Image: registry.gitlab.eox.at/eox/hub/bucket-operator:1.1.0
  * GitHub: https://github.com/EOEPCA/rm-bucket-operator/
