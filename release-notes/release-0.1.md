# EOEPCA System - Release 0.1

## Functionality

Release 0.1 is designed to satisfy the following use case...

1. User login in accordance with Epic EOEPCA-1 (User Login)
   * See EOEPCA-1 for elaboration of capabilities to be demonstrated

1. User obtains auth token (bearer) for platform access via CLI

1. User must be authenticated to access ADES endpoints
   * implies PEP<br>
   _This initial version of the PEP will register the whole ADES as a UMA Resource, therefore intercepting ANY request and enforcing authentication (assuming not enough time to include any specific authorisation)_

1. ADES is protected by a PEP that supports auth tokens obtained through User Login

1. User discovers available applications:
   * at the application catalogue (provided temporarily by Terradue Catalogue)
   * at the ADES via WPS (GetCapabilties)
   * at the ADES via OGC API Processes (REST/JSON)

1. User obtains details for a specific process from the ADES:
   * at the ADES via WPS (DescribeProcess)
   * at the ADES via OGC API Processes (REST/JSON)

1. Basic resource catalogue providing discovery of dataset inputs for processing

1. User invokes execution of an existing process at the ADES:
   * at the ADES via WPS (ExecuteProcess)
   * at the ADES via OGC API Process (REST/JSON)
   * specifies input data and parameterisation

1. User monitors process execution
   * at the ADES via WPS (GetStatus)
   * at the ADES via OGC API Process (REST/JSON)
   * User obtains outcome and downloads results
   * (would be nice if this was limited to the invoking user)

1. User deploys their own containerised application at the ADES
   * at the ADES via WPS (Execute + DeployProcess Service)

1. User undeploys their containerised application at the ADES
   * at the ADES via WPS (Execute + UndeployProcess Service)

## Building Blocks

This section identifies the version of the building blocks components comprising this release, and provides links for further information.

### User Management

### Login Service

* **um-login-persistence (version 0.1.1)**
  * Image: eoepca/um-login-persistence:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-login-persistence
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-persistence

* **um-login-passport (version 0.1.1)**
  * Image: eoepca/um-login-passport:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-login-passport
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-login-passport

* **um-pep-engine (version 0.1.1)**
  * Image: eoepca/um-pep-engine:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-pep-engine
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-pep-engine

* **um-user-profile (version 0.1.1)**
  * Image: eoepca/um-user-profile:v0.1.1
  * GitHub: https://github.com/EOEPCA/um-user-profile
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/um-user-profile

The Login Service uses the Gluu Server, via the following container images:
* gluufederation/config-init:4.1.1_02
* gluufederation/wrends:4.1.1_01
* gluufederation/oxauth:4.1.1_03
* gluufederation/oxtrust:4.1.1_02

## Processing and Chaining

* **proc-ades (version 0.1)**
  * Image: eoepca/proc-ades:v0.1
  * GitHub: https://github.com/EOEPCA/proc-ades
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/proc-ades

## Resource Management

Implementation of the resource management components has not yet begun.

* **workspace (version 0.1)**<br>
In support of the ADES (proc-ades) a 'dummy' workspace component is deployed using NextCloud () to provide a WebDAV endpoint:
  * Image: nextcloud:19
  * DockerHub: https://hub.docker.com/_/nextcloud

## System

* **kubeproxy (version 0.1)**
  * Image: eoepca/kubeproxy:v0.1
  * GitHub: https://github.com/EOEPCA/kubeproxy
  * DockerHub: https://hub.docker.com/repository/docker/eoepca/kubeproxy
