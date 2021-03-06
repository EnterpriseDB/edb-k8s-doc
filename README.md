# EDB Containers and Kubernetes Operator

The world loves PostgreSQL. 

If you work with developers or data scientists or anyone wrangling data, you’ll probably see a sticker with the tusks and trunk of the PostgreSQL elephant on the lid of a nearby laptop. EDB has a lot to do with that.  We’ve been major contributors to PostgreSQL since the beginning, and we are proud to call thousands of boundary pushing customers our partners.

Although we are proud, we are not resting on our laurels. EDB continues to evolve the core PostgreSQL database server's capabilities and extends the PostgreSQL and cloud ecosystems by providing tools and automation. EDB believes Kubernetes and containers are essential for minimizing your database management responsibilities while maximizing your IT budget.  As you begin or expand your journey to Kubernetes for PostgreSQL, we want to be your first choice.

Ease of deployment and the scalability offered by the EDB Kubernetes Operator will allow you to provision and manage EDB Postgres Advanced Server and PostgreSQL containers in a cloud-agnostic environment. EDB will help you build portable, reliable, and responsive databases for your application environments.   

Common use cases supported include:
* Local workstation development
* Experimental developer sandboxes
* Integration with CI/CD pipelines
* Oracle migration feasibility assessments
* 99.9% available production environments (coming soon)


## Getting Started

### Prerequisites

1. Contact [EDB](https://github.com/EnterpriseDB/edb-k8s-doc/issues/new?assignees=&labels=&template=quay-io-request-access.md&title=) to obtain access to EDB's Quay.io repositories.  
   * If you are an existing user, enter your Quay.io user name.  
   * If you are a new user, enter your email address.

2. Activate access to the private EDB repositories by using the link provided in the invite email for [Quay.io](https://quay.io).  You will receive the invite email within 24 hours. 
   * Existing users can immediately access the [EDB repositories](https://quay.io/organization/edb).
   * For new users, a Quay.io account is created; after which the EDB repositories will be accessible.


### Deployment

EDB provides several methods for deploying our container images.

   * [Docker](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/Docker)
   * [Helm Charts](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-helm)
   * [Kubernetes CLI (kubectl)](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-CLI)
   * [Kubernetes Operator](https://github.com/EnterpriseDB/edb-k8s-doc/tree/master/k8s-operator)
