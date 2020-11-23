# EOEPCA System - Release 0.2

Release 0.2 is an initial alpha release that includes alpha versions of the following building blocks:
* Login Service
* User Profile
* Policy Enforcement Point (PEP)
* Policy Decision Point (PDP)
* Application Deployment & Execution Service (ADES)

## Release 0.1 Scope

The release demonstrates the following capabilities:
* User authentication:
  * Login with GitHub
  * Login with username/password
* Client Registration
  * Dynamic client registration via SCIM endpoint<br>
* Authorisation
  * Dynamic Resource Registration<br>
    *Resource servers dynamic registration of resources*
  * Basic resource protection<br>
    *Enforcing a simple policy that user must be authenticated to access the ADES resource*
  * Policy-based resource protection<br>
    *Enforcing policy based upon policy rules maintained in the PDP*
* Processing Capabilities (ADES resource server)
  * OGC WPS 2.0 and OGC API Processes interfaces
  * List available processes
  * Deploy process (docker container with CWL application package)
  * Execute process (create job)
  * Get job status
  * Data stage-in via OpenSearch catalogue reference
  * Data stage-out to WebDAV endpoint (Nextcloud as a stub)
  * Undeploy process
  * Integration of Calrissian CWL Workflow engine
    *Provides native Kubernetes integration and out-of-the-box support for a variety of execution patterns - such fan-in, fan-out, etc.*

## Building Blocks

This section identifies the version of the building blocks components comprising this release, and provides links for further information.

### User Management

### Login Service

* **um-login-persistence (version 0.2)**
  * Image: eoepca/um-login-persistence:v0.2
  * GitHub: https://github.com/EOEPCA/um-login-persistence
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-persistence

* **um-login-passport (version 0.1.1)**
  * Image: eoepca/um-login-passport:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-login-passport
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-passport

* **um-pep-engine (version 0.2.5)**
  * Image: eoepca/um-pep-engine:v0.2.5
  * GitHub: https://github.com/EOEPCA/um-pep-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pep-engine

* **um-user-profile (version 0.2)**
  * Image: eoepca/um-user-profile:v0.2
  * GitHub: https://github.com/EOEPCA/um-user-profile
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-user-profile

The Login Service uses the Gluu Server, via the following container images:
* gluufederation/config-init:4.1.1_02
* gluufederation/wrends:4.1.1_01
* gluufederation/oxauth:4.1.1_03
* gluufederation/oxtrust:4.1.1_02

## Processing and Chaining

* **proc-ades (version 0.2.4)**
  * Image: eoepca/proc-ades:0.2.4
  * GitHub: https://github.com/EOEPCA/proc-ades
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/proc-ades

* **app-stagein (version 0.7)**
  * Image: eoepca/app-stagein:0.7
  * GitHub: https://github.com/EOEPCA/app-stagein
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/stage-in

* **app-stageout (version 0.2)**
  * Image: eoepca/app-stageout:0.2
  * GitHub: https://github.com/EOEPCA/app-stageout
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/stage-out

## Resource Management

Resource Management components are under development, but have not yet been released to the EOEPCA system.

* **workspace (version 0.1)**<br>
In support of the ADES (proc-ades) a 'dummy' workspace component is deployed using [NextCloud](https://nextcloud.com/) to provide a WebDAV endpoint:
  * Image: nextcloud:19
  * DockerHub: https://hub.docker.com/_/nextcloud

## Further Information

For further project information, including details of how to make a deployment of the EOEPCA system, please see the [main project page](../README.md).
