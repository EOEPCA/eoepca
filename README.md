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
[![License][license-shield]][license-url]
[![Build][build-shield]][build-url]


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
- [Getting Started](#getting-started)
- [System Documentation](#system-documentation)
- [Technical Domains](#technical-domains)
  - [User Management](#user-management)
  - [Processing and Chaining](#processing-and-chaining)
  - [Resource Management](#resource-management)
- [Releases](#releases)
- [Issues](#issues)
- [License](#license)
- [Contact](#contact)
- [Acknowledgements](#acknowledgements)


<!-- ABOUT THE PROJECT -->
## About The Project

EO Exploitation Platform Common Architecture (EOEPCA)

The goal of the “Common Architecture” is to define and agree the technical interfaces for the future exploitation of Earth Observation data in a distributed environment. The Common Architecture will thus provide the interfaces to facilitate the federation of different EO resources into a “Network of EO Resources”. The “Common Architecture” will be defined using open interfaces that link the different resources (building blocks) so that a user can efficiently access and consume the disparate services of the “Network of EO Resources”.

This repository represents the system integration of the building block that comprise the **Reference Implementation** of the Common Architecture.

The system is designed for deployment to cloud infrastructure orchestrated by a Kubernetes cluster. We include here the automation required to provision, deploy and test the emerging EOEPCA system.

<!-- GETTING STARTED -->
## Getting Started

The EOEPCA system deployment comprises the following steps, each of which is covered with dedicated instructions, as follows:
* [Infrastructure (CREODIAS) Setup](./creodias/README.md)
* [Kubernetes Cluster Setup](./kubernetes/README.md)
* [EOEPCA System Deployment](./terraform/test/README.md)
* [Acceptance Test](./test/acceptance/README.md)


## System Documentation

* [Use Case Analysis Document](https://eoepca.github.io/use-case-analysis/)
* [Master System Design Document](https://eoepca.github.io/master-system-design/)
* [Master System ICD Document](https://eoepca.github.io/master-system-icd/)


## Technical Domains

### User Management

Building Block | Repository | Documentation
---------------|------------|--------------
Login Service | https://github.com/EOEPCA/um-login-service | https://eoepca.github.io/um-login-service/
User Profile | https://github.com/EOEPCA/um-user-profile | https://eoepca.github.io/um-user-profile/
Policy Enforcement Point (PEP) | https://github.com/EOEPCA/um-pep-engine | https://eoepca.github.io/um-pep-engine/
Policy Decision Point (PDP) | https://github.com/EOEPCA/um-pep-engine | https://eoepca.github.io/um-pep-engine/

### Processing and Chaining

Building Block | Repository | Documentation
---------------|------------|--------------
Application Deployment & Execution Service (ADES) | https://github.com/EOEPCA/proc-ades | https://eoepca.github.io/proc-ades/

### Resource Management

Not started yet


<!-- Releases -->
## Releases

EOEPCA system releases are made to provide integrated deployments of the developed building blocks. The release history is as follows:

* 22/06/2020 - [Release 0.1](release-notes/release-0.1.md)

<!-- ISSUES -->
## Issues

See the [open issues](https://github.com/EOEPCA/eoepca/issues) for a list of proposed features (and known issues).

<!-- LICENSE -->
## License

Distributed under the Apache-2.0 License. See `LICENSE` for more information.


<!-- CONTACT -->
## Contact

Project Link: [Project Home (https://eoepca.github.io/)](https://eoepca.github.io/)


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

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
[build-url]: https://travis-ci.com/github/EOEPCA/eoepca
[product-screenshot]: images/screenshot.png
