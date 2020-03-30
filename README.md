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
    <a href="https://github.com/EOEPCA/template-svce"><strong>Explore the docs »</strong></a>
    <br />
    <a href="https://github.com/EOEPCA/template-svce">View Demo</a>
    ·
    <a href="https://github.com/EOEPCA/template-svce/issues">Report Bug</a>
    ·
    <a href="https://github.com/EOEPCA/template-svce/issues">Request Feature</a>
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

- Local environment - It creates a testing environment in a Minikube cluster deployed on the local machine  
1. `cd terraform/test`
2. `terraform init`
3. `terraform apply --auto-approve`

- Staging environment - It creates a testing environment on an Openstack environment provided by a Network-of-Resources provider (e.g. a DIAS platform)
1. [Register yourself into openstack provider and obtain cloud.key for access]
2. [Obtain detailed credential for accessing the environment and modify terraform/staging/variables.tf with this information]
3. `cd terraform/staging`
4. `terraform init`
5. `terraform apply --auto-approve`
6. [Output is master IP]
7. [Modify provisioning/hosts file to include the obtained master IP address]
8. `ansible-playbook provisioning/playbook.yml --inventory provisioning/hosts --limit masters --user eouser --private-key ~/.ssh/cloud.key`
9. [TODO: remote installation of kubernetes cluster]
10. [This needs ssh-ing into the master node, downloading the source code repository and terraforming it locally]
 
### Testing

Once installed, developers can deploy environments for these pipelines:
- local test: executing `sh travis/test_template-service.sh` will create the test environment, deploy a sample service and perform simple acceptance tests on that service.

- [TODO] remote integration: executing `sh travis/stage_template-service.sh` will create the staging environment, deploy a sample service and perform simple acceptance tests on that service. 

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
* []()
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
