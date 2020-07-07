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
- [Releases](#releases)
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
2. Either edit and modify the variables values in deployEOEPCA.sh or define needed environment variables:
- `export DOCKER_EMAIL=[Email of the account with access to the Dockerhub EOEPCA repository]`
- `export DOCKER_USERNAME=[User name of the account with access to the Dockerhub EOEPCA repository]`
- `export DOCKER_PASSWORD=[Password of the account with access to the Dockerhub EOEPCA repository]`
- `export WSPACE_USERNAME=[User name of the account with access to the workspace]`
- `export WSPACE_PASSWORD=[Password of the workspace account]`
- `export NFS_SERVER_ADDRESS=[Address of the NFS server, in the internal subnet]`
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

Before the setupOpenstack step, you may want to configure you system environment. You may edit `./inventory/cf2-kube/cluster.tfvars` following the inline instructions.

Once you have the underlying openstack/kubernetes environment, you can proceed to deploy the EOEPCA system itself. You should specify the same environment variables than in the local environment case (above). Use this call:

7. `./deployEOEPCA.sh`

This will deploy an EOEPCA system reachable over the internet at https://test.eoepca.org.

You can alternatively comment the terraforming and test execution tasks in `eoepca.yml`, SSH into the bastion node and run the `eoepca/terraform/test/deployEOEPCA.sh` script from inside the machine to receive more feedbakc and debug any problems.

---
Remember to update the DNS tables so the domain could be reacheable from the internet

---
### Testing

Once installed, developers can deploy environments for these pipelines:
- local test: 
1. executing `setupMinikube.sh` will create the local environment, 
2. `setupRobot.sh` will create the test environment, and 
3. `sh travis/acceptanceTest.sh` will perform all acceptance tests on the deployed system running locally.

- staging test: 
1. executing `sh travis/acceptanceTest.sh` will perform all acceptance tests on the deployed system at http://test.eoepca.org.

<!-- Releases -->
## Releases

EOEPCA system releases are made to provide integrated deployments of the developed building blocks. The release history is as follows:

* 22/06/2020 - [Release 0.1](release-notes/release-0.1.md)


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
