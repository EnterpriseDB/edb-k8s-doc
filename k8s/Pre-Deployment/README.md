# Pre-Deployment Steps For Helm Chart and CLI
Complete the steps below to make PostgreSQL and EDB Postgres Advanced Server containers ready for deployment.


NOTE: If you are redeploying in the same namespace, cleanup using the instructions [here](../Cleanup/README.md)

## 1. Create namespace in your k8s cluster
NOTE: If you are planning to reuse an existing namespace, you can skip this step.

    kubectl create ns <your-namespace>
For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)



## 2. Switch to your namespace
a. For OpenShift:

    oc project <your-namespace>
 
b. For other k8s platforms:

    kubectl config set-context --current --namespace= <your-namespace>


## 3. Create staging objects
The following k8s objects are used to stage the deployment:

| Object Type | Object Name       | Scope        |Description             |
|-------------|-------------------|--------------|------------------------|
| [Secret](https://kubernetes.io/docs/concepts/configuration/secret/)      | quay-regsecret    | Namespace    | Stores credentials to EDB image repositories on quay.io                  |
| [Configmap](https://kubernetes.io/docs/concepts/configuration/configmap/)      | edb-db-custom-config    | Namespace    |     Stores custom postgresql.conf settings. Needed for StatefulSet deployments only.                   |
| [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)      | edb    | Namespace    |  Service account for pods running in the namespace                                             |
| [Security Context Constraint (SCC)](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)     | edb-operator-scc    | Cluster    | Privilege and access control settings for pods running in the namespace. Needed for the OpenShift platform only.|

Create the staging objects using the commands below: 


- Registry secret for EDB Container Registry (quay.io)

        kubectl create secret docker-registry quay-regsecret \
        --docker-server=quay.io \
 	    --docker-username=<your-quay.io-username> \
 	    --docker-password=<your-quay.io-password> \
 	    --docker-email=<your-quay.io-email>

    For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)

- Service account

        kubectl apply -f service-account.yaml

    If running on OpenShift, also create securty context (SCC):

        kubectl apply -f scc.yaml
        oc adm policy add-scc-to-user edb-operator-scc -z edb

If deploying as a statefulset, also create configmap for custom postgresql.conf settings:

- Configmap for custom postgresql.conf settings

        kubectl apply -f configmap.yaml