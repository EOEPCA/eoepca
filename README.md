<!--
*** 
*** To avoid retyping too much info. Do a search and replace for the following:
*** template-svce, twitter_handle, email
-->

<!-- PROJECT SHIELDS -->
<!--
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
![Build][build-shield]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/EOEPCA/eoepca">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">EOEPCA system</h3>

  <p align="center">
    EOEPCA Reference Implementation - System
    <br />
    <a href="https://github.com/EOEPCA/eoepca"><strong>Explore the docs »</strong></a>
    <br />
    <a href="https://github.com/EOEPCA/eoepca">View Demo</a>
    ·
    <a href="https://github.com/EOEPCA/eoepca/issues">Report Bug</a>
    ·
    <a href="https://github.com/EOEPCA/eoepca/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

- [Table of Contents](#table-of-contents)
- [About The Project](#about-the-project)
  - [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Testing](#testing)
- [Usage](#usage)
- [Release](#releases)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://example.com)

Here's a blank template to get started:
**To avoid retyping too much info. Do a search and replace with your text editor for the following:**
`template-svce`, `twitter_handle`, `email`

### Built With

* [Terraform](https://terraform.io/)
* [Ansible](https://ansible.com)
* [Kubernetes](https://kubernetes.io)
* [Minikube](https://github.com/kubernetes/minikube)
* [Docker](https://docker.com)

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Things you need to use the software and how to install them.
* [Terraform](https://terraform.io/) 
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

### Installation

*Local environment*

It creates a testing environment in a Minikube cluster deployed on the local machine  
1. `cd terraform/test`
2. Define needed environment variables:
- `export DOCKER_EMAIL=[Email of te account with access to the Dockerhub EOEPCA repository`
- `export DOCKER_USERNAME=[User name of te account with access to the Dockerhub EOEPCA repository`
- `export DOCKER_PASSWORD=[Password of te account with access to the Dockerhub EOEPCA repository`
3. `./deployEOEPCA.sh`

This will create a system accesible from local node at https://test.eoepca.org


*Staging environment*

It creates a testing environment on an Openstack environment provided by a Network-of-Resources provider (e.g. a DIAS platform)
1. [Register yourself into openstack provider and obtain cloud.key for access]
2. [Obtain detailed credential for accessing the environment and modify terraform/staging/openrc.sh with this information]
3. `cd terraform/staging`
4. `source openrc.sh` [You may be asked for the password if not already set]
5. `./setupOpenstack.sh --apply` [or --destroy to remove]
6. `./setupKubernetes.sh`
- You would be asked of VAULT_PASSWORD environment variable. Ask your EOEPCA admin if you don't have it.

Once you have the underlying openstack/kubernetes environment, you can proceed to deploy the EOEPCA system itself. Use this call:

7. `./deployEOEPCA.sh`

This will deploy an EOEPCA system reachable over the internet at https://staging.eoepca.org

### Testing

Once installed, developers can deploy environments for these pipelines:
- local test: executing `sh travis/test_template-service.sh` will create the test environment, deploy a sample service and perform simple acceptance tests on that service.

- [TODO] remote integration: executing `sh travis/stage_template-service.sh` will create the staging environment, deploy a sample service and perform simple acceptance tests on that service.

You would see a result similar to this:
`Tuesday 14 April 2020  12:18:45 +0000 (0:00:02.246)       0:03:01.552 ********* 
ok: [45.130.30.38] => {
  "test_result.stdout_lines": [
    "Testing connectivity with the infrastructure",
    "MiniKube Master IP is 172.16.0.2:6443",
    "Testing connectivity with the services",
    "Cluster IP of frontend is 45.130.30.36:8081",
    "{",
      "  \"result\": \"search results\"",
    "}",
    "HTTP/1.1 200 OK",
    "Server: nginx/1.7.9",
    "Date: Tue, 14 Apr 2020 12:21:40 GMT",
    "Content-Type: application/json",
    "Content-Length: 27",
    "Connection: keep-alive",
    "",
    "{\"result\":\"search results\"}"
  ]
}`

Notice the Cluster IP of frontend. You may also test the API entrypoint yourself with:
  `curl http://[FRONTEND_IP]:[PORT]/search`
 

<!-- Releases -->
## Releases

EOEPCA system releases are made to provide integrated deployments of the developed building blocks. The release history is as follows:

* 22/06/2020 - [Release 0.1](release-notes/release-0.1)


<!-- USAGE EXAMPLES -->
## Usage

TBW

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/EOEPCA/eoepca/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the Apache-2.0 License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - email

Project Link: [https://github.com/EOEPCA/eoepca](https://github.com/EOEPCA/eoepca)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* []()
* Deployment of Kubernetes staging environment over an Openstack infrastructure is based on the [kubespray](https://github.com/kubernetes-sigs/kubespray) project
* README.md is based on [this template](https://github.com/othneildrew/Best-README-Template) by [Othneil Drew](https://github.com/othneildrew).



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/EOEPCA/eoepca.svg?style=flat-square
[contributors-url]: https://github.com/EOEPCA/eoepca/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/EOEPCA/eoepca.svg?style=flat-square
[forks-url]: https://github.com/EOEPCA/eoepca/network/members
[stars-shield]: https://img.shields.io/github/stars/EOEPCA/eoepca.svg?style=flat-square
[stars-url]: https://github.com/EOEPCA/eoepca/stargazers
[issues-shield]: https://img.shields.io/github/issues/EOEPCA/eoepca.svg?style=flat-square
[issues-url]: https://github.com/EOEPCA/eoepca/issues
[license-shield]: https://img.shields.io/github/license/EOEPCA/eoepca.svg?style=flat-square
[license-url]: https://github.com/EOEPCA/eoepca/blob/master/LICENSE
[build-shield]: https://www.travis-ci.com/EOEPCA/eoepca.svg?branch=master
[product-screenshot]: images/screenshot.png
