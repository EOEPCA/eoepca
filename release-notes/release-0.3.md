# EOEPCA System - Release 0.3

Release 0.3 is an initial release that includes versions of the following building blocks:
* Login Service
* User Profile
* Policy Enforcement Point (PEP)
* Policy Decision Point (PDP)
* Application Deployment & Execution Service (ADES)
* Resource Catalogue
* Data Access Services


## Release 0.3 Scope

The release demonstrates the following capabilities:
* User authentication:
  * Login with GitHub
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
  * List available processes
  * Deploy process (docker container with CWL application package)
  * Execute process (create job)
  * Get job status
  * Data stage-in via OpenSearch catalogue reference
  * Data stage-out to S3 bucket
  * Undeploy process
  * Integration of Calrissian CWL Workflow engine<br>
    *Provides native Kubernetes integration and out-of-the-box support for a variety of execution patterns - such fan-in, fan-out, etc.*
  * Dedicated user 'context' within ADES service
* Resource Catalogue
  * TBD - EOfarm - describe most relevant/significant capabilities
* Data Access Service
  * TBD - EOX - describe most relevant/significant capabilities
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


## What's new

* Rule-based policies for resource protection
* Dynamic registration of protected (per user) ADES resources
* Dedicated user 'context' within ADES service
* ADES stage-in/out using STAC manifests
* ADES stage-out to S3 bucket
* First version of Resource Catalogue
* First version of Data Access Components
* Integration of ADES with Resource Catalogue
* Helm charts for deployment of all components
* System deployment using flux continuous delivery kubernetes operator for GitOps


## Building Blocks

This section identifies the version of the building blocks components comprising this release, and provides links for further information. For each, we include an 'Example' deployment configuration using a flux HelmRelease resource - these must be adapted for individual deployments.

### User Management

### Login Service

* Version: 0.3
* Chart version: 0.1.0
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/login-service
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/user-management/um-login-service.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-login-service
* README: https://github.com/EOEPCA/um-login-service/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-login-service/wiki
* Design: https://eoepca.github.io/um-login-service/SDD/
* ICD: https://eoepca.github.io/um-login-service/ICD/

#### Containers

* **um-login-persistence (version 0.3)**
  * Image: eoepca/um-login-persistence:v0.3
  * GitHub: https://github.com/EOEPCA/um-login-persistence
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-persistence

* **um-login-passport (version 0.1.1)**
  * Image: eoepca/um-login-passport:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-login-passport
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-passport

Additional container images:
* Gluu Server:
  * gluufederation/config-init:4.1.1_02
  * gluufederation/wrends:4.1.1_01
  * gluufederation/oxauth:4.1.1_03
  * gluufederation/oxtrust:4.1.1_02


### Policy Enforcement Point (PEP)

* Version: 0.3.1
* Chart version: 0.1.0
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/pep-engine
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/user-management/um-pep-engine.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pep-engine
* README: https://github.com/EOEPCA/um-pep-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pep-engine/wiki
* Design: https://eoepca.github.io/um-pep-engine/SDD/
* ICD: https://eoepca.github.io/um-pep-engine/ICD/

#### Containers

* **um-pep-engine (version 0.3.1)**
  * Image: eoepca/um-pep-engine:v0.3.1
  * GitHub: https://github.com/EOEPCA/um-pep-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pep-engine

Additional container images:
* mongo:4.0.23 (latest)


### Policy Decision Point (PDP)

* Version: 0.3
* Chart version: 0.1.1
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/pdp-engine
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/user-management/um-pdp-engine.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-pdp-engine
* README: https://github.com/EOEPCA/um-pdp-engine/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-pdp-engine/wiki
* Design: https://eoepca.github.io/um-pdp-engine/SDD/
* ICD: https://eoepca.github.io/um-pdp-engine/ICD/

#### Containers

* **um-pdp-engine (version 0.3)**
  * Image: eoepca/um-pdp-engine:v0.3
  * GitHub: https://github.com/EOEPCA/um-pdp-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pdp-engine

Additional container images:
* mongo:4.0.23 (latest)


### User Profile

* Version: 0.3
* Chart version: 0.1.1
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/user-profile
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/user-management/um-user-profile.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/um-user-profile
* README: https://github.com/EOEPCA/um-user-profile/blob/develop/README.md
* Wiki: https://github.com/EOEPCA/um-user-profile/wiki
* Design: https://eoepca.github.io/um-user-profile/
* ICD: ???

#### Containers

* **um-user-profile (version 0.2)**
  * Image: eoepca/um-user-profile:v0.3
  * GitHub: https://github.com/EOEPCA/um-user-profile
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-user-profile


## Processing and Chaining

### ADES

* Version: 0.3
* Chart version: 0.1.0
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/ades
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/processing-and-chaining/proc-ades.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: https://github.com/EOEPCA/proc-ades
* README: https://github.com/EOEPCA/proc-ades/blob/master/README.md
* Wiki: https://github.com/EOEPCA/proc-ades/wiki
* Design: ???
* ICD: ???

#### Containers

* **proc-ades (version 'devlatest')**  ???
  * Image: eoepca/proc-ades:devlatest   ???
  * GitHub: https://github.com/EOEPCA/proc-ades
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/proc-ades

Additional container images:
* Stage-in: terradue/stars-t2:latest
* Stage-out: terradue/stars:latest


## Resource Management

### Resource Catalogue

* Version: 0.3
* Chart version: 0.1.5
* Helm chart: https://github.com/EOEPCA/eoepca/tree/develop/system/charts/rm-resource-catalogue
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/resource-management/hr-resource-catalogue.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: ???
* README: ???
* Wiki: ???
* Design: ???
* ICD: ???

#### Containers

Additional container images:
* Database: postgis/postgis:12-3.1
* pycsw: geopython/pycsw:latest


### Data Access Services

* Version: 0.3
* Chart version: ???
* Helm chart: ???
* Example: https://github.com/EOEPCA/eoepca/blob/develop/system/clusters/develop/resource-management/hr-data-access.yaml

#### Resources

Resources to support deployment and configuration...

* GitHub repository: ???
* README: ???
* Wiki: ???
* Design: ???
* ICD: ???

#### Containers

* **rm-data-access-core (version 'latest')**  ???
  * Image: eoepca/rm-data-access-core   ???
  * GitHub: https://github.com/EOEPCA/rm-data-access-core
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/rm-data-access-core

Additional container images:
* registry.gitlab.eox.at/esa/prism/vs/pvs_client:release-1.1.1
* registry.gitlab.eox.at/esa/prism/vs/pvs_cache:release-1.1.1
* ???

