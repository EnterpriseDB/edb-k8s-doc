# EDB-Values

Several sample values.yaml files are provided. Please refer to values.yaml for a complete list of all options as well as a description of how they work. 

## Prerequisities
The examples assume that following prerequisite objects have been met.  

| Object Type | Object Name       | Scope        |Description |
|-------------|-------------------|--------------|------------------------|
| [Secret](https://kubernetes.io/docs/concepts/configuration/secret/)      | quay-regsecret| Namespace|Stores credentials to EDB image repositories on quay.io                  |
| [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)      | edb    | Namespace    |  Service account for pods running in the namespace |
| [Configmap](https://kubernetes.io/docs/concepts/configuration/configmap/)| edb-db-custom-config| Namespace | Stores custom postgresql.conf settings.<br>Needed for StatefulSet deployments only.                                            |
| [Security Context Constraint (SCC)](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)     | edb-operator-scc    | Cluster    | Privilege and access control settings for pods running<br>in the namespace. Needed for OpenShift only.|

## Deploying
To use the charts with the provided sample values files:
* **Accept the [End User License Agreement (EULA)](https://www.enterprisedb.com/limited-use-license) by changing the default for `acceptEULA` from No to Yes**
* Make other changes to the sample values as desired
* Run `helm install my-release <chart> -f values-<sample>.yaml`
