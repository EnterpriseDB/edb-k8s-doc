# edb-k8s-se

Customers can deploy and use Postgres containers from EDB using the steps described here. The EDB Postgres containers come in two flavors:

- Community Postgres
- EDB Postgres Advanced Server (EPAS)

The containers can be deployed on the following platforms:

- Docker

    The official documention for docker is available [here](https://docs.docker.com/)

- Kubernetes

    The official documention for kubernetes is available [here](https://kubernetes.io/docs/home/)


## Getting started

- Download sample files by cloning (this) git repo and change to root directory
        
        git clone https://github.com/EnterpriseDB/edb-k8s-se.git
        cd edb-k8s-se

- Obtain credentials to access EDB image repositories on [quay.io](https://quay.io/edb)

- Deploy EDB containers using the deployment methods listed below


## Images

You can find more information on our images, and how to run them with docker / docker-compose in the [Images](Images) folder.


## Deployment Methods

- Docker: Setup and examples of deploying EDB Postgres containers on Docker Desktop is described [here](Docker)

- Helm Chart: Setup and examples of deploying EDB Postgres containers in k8s using Helm charts is described [here](k8s/helm).

- Command-line Interface (CLI): Setup and examples of deploying EDB Postgres containers in k8s using the CLI is described [here](k8s/CLI).