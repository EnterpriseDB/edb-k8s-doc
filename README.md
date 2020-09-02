# EDB Containers and Kubernetes Operator

The world loves PostgreSQL. 

If you work with developers or data scientists or anyone wrangling data, you’ll probably see a sticker with the tusks and trunk of the PostgreSQL elephant on the lid of a nearby laptop. EDB has a lot to do with that.  We’ve been major contributors to PostgreSQL since the beginning, and we are proud to call thousands of boundary pushing customers our partners.

Although we are proud, we are not resting on our laurels. EDB continues to evolve the capabilities of the core PostgreSQL database server, but also extends the PostgreSQL and cloud ecosystems by providing tools and automation.  EDB believes Kubernetes and containers are essential for you to minimize your database management responsibilities while maximizing your IT budget.  As you begin or expand your journey to Kubernetes for PostgreSQL, we want to be your first choice.

Ease of deployment and the scalability offered by the EDB Kubernetes Operator will allow you to provision and manage EDB Postgres Advanced Server and PostgreSQL containers in a cloud-agnostic environment. EDB will help you build portable, reliable, and responsive databases for your application environments.   

Common use cases supported include:
* Local workstation development
* Experimental developer sandboxes
* Integration with CI/CD pipelines
* Oracle migration feasibility assessments
* 99.9% available production environments (coming soon)


## Getting Started

1. Obtain credentials to access the  [quay.io](https://quay.io) container registry.  This repository is where EDB container images are published. 

1. Obtain access to [EDB's quay repositories](https://quay.io/organization/edb) by contacting [EDB](https://github.com/EnterpriseDB/edb-k8s-doc/issues/new?assignees=&labels=&template=quay-io-request-access.md&title=).

### Docker

1. Deploy EDB container images using:

   * [Command Line Interface (CLI)](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/Docker)
   * Docker Compose

### Kubernetes

1. (For OpenShift) Create a cluster level storage class to map a platform storage provisioner to `edb-storageclass`. Each platform hosting Kubernetes clusters has their own storage provisioners that are used for persistent volume claims; mapping them to a common name simplifies the deployment examples provided.  The following commands (and example yaml) can be used to define `edb-storageclass` for two of the most common public cloud platforms:

   * AWS EBS `kubectl apply -f storage-class-aws-ebs.yaml`

   * GCE Persistent Disk `kubectl apply -f storage-class-gce-pd.yaml`

   For additional examples, refer to the [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) documentation provided by Kubernetes.
   
1. (For OpenShift) Create a Security Context Constraint (SCC) which includes the required permissions for successful deployment to OpenShift 4.4 or later by using the following command:
   ```
   kubectl apply -f setup/scc.yaml
   ```
   
1. Deploy EDB container images using:

   * [Helm Charts](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-helm)
   * [Command Line Interface (CLI)](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-CLI)
   * [Operator](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-operator)
