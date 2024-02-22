## Contributing to EOEPCA

We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix

This document sets out our guidelines and best practices for such contributions and is based on the [Contributing to Open Source Projects Guide](https://www.contribution-guide.org)

## We Develop with Github
We use GitHub to host code and track issues, as well as accept pull requests.

## Code of Conduct
Contributors to this project are expected to act respectfully toward all others in accordance with our [Code of Conduct](/code-of-conduct.md)

## Submitting Bugs
Before submitting a bug, please do the following:

- Perform basic **troubleshooting**:
    - Browse the [open issues](https://github.com/EOEPCA/eoepca/issues) to ensure it's not a known issue
    - Depending how long it takes for the team to merge your work, the copy of ``develop`` you're working on may become out of date. In this unlikely event, please ensure to rebase or git reset

## Contributions and Licensing
### Contributor License Agreement
Any contributions will be under our [License](/LICENSE) as per [GitHub's terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#6-contributions-under-repository-license)

### Pull Requests
When making pull requests, please aim to follow the [best practices](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/best-practices-for-pull-requests). In short:
- Make smaller PRs
- Include useful descriptions and titles
- Review your own PR before submitting
- Provide context and guidance 

### Version Control Branching
- **Fork** the [EOEPCA Repository](https://github.com/EOEPCA/eoepca) into your GitHub account
- Make a **new branch** for your work - This approach supports our GitOps approach to deployment with Flux Continuous Delivery, which requires write access to your git repository for deployment configurations. This also makes it easy for others to take individual sets of changes from your repo. 
- The ``develop`` branch should be used for the latest development.

### Code Formatting
- Please follow the coding conventions and styles used in the EOEPCA repository


