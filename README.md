# EDB for Kubernetes

Kubernetes provides business benefits:

- Manage Postgres at scale
- Deploy anywhere: Run Postgres on public, private, and hybrid clouds
- Plug into existing DevOps pipelines

Docker Containers provide business benefits:

- Easy to deploy
- Build experimental sandboxes
- You can maximise your resource budget by not having unused servers

The EDB Postgres containers are available in two flavors:

- EDB Postgres Advanced Server (EPAS)
- PostgreSQL


You can deploy containers on the following platforms:

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


## Deployment Methods

- Docker: Setup and examples of deploying EDB Postgres containers on Docker Desktop is described [here](Docker)

- Helm Chart: Setup and examples of deploying EDB Postgres containers in k8s using Helm charts is described [here](k8s/helm).

- Command-line Interface (CLI): Setup and examples of deploying EDB Postgres containers in k8s using the CLI is described [here](k8s/CLI).
