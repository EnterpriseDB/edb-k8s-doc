# Helm
Some customers may prefer to deploy EDB containers using Helm rather than using Docker, the Operator, or the native Kubernetes CLI.  Sample commands and examples are provided for deploying PostgreSQL and EDB Postgres Advanced Server container images to Kubernetes.

## Prerequisites

Complete all of the prerequisites before using the Helm charts. The prerequisites are provided in the sample files. You can modify the sample files as required by your deployment. 

### Workstation Prerequisites
1. Install [Helm 3](https://helm.sh/docs/intro/install/).

### Cluster Prerequisites

1. Obtain access to a Kubernetes cluster.  

1. Create a cluster level storage class to map a platform storage provisioner to `edb-storageclass`. Each platform hosting Kubernetes clusters has their own storage provisioners that are used for persistent volume claims; mapping them to a common name simplifies the deployment examples provided.  The following commands (and example yaml) can be used to define `edb-storageclass` for two of the most common public cloud platforms:

   * AWS EBS `kubectl apply -f setup/storage-class-aws-ebs.yaml`

   * GCE Persistent Disk `kubectl apply -f setup/storage-class-gce-pd.yaml`

   For additional examples, refer to the [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) documentation provided by Kubernetes.
   
1. (For OpenShift) Create a Security Context Constraint (SCC) which includes the required permissions for successful deployment to OpenShift 4.4 or later by using the following command:
   ```
   kubectl apply -f setup/scc.yaml
   ```

### Namespace Prerequisites
1. Obtain access to an existing namespace or create a new [namespace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace) to hold the deployment using the following command:
   ```
   kubectl create ns <your-namespace>
   ```
   
1. Create a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/) for pulling images from quay.io; the secret will be used when deploying container images:
   ```
   kubectl create secret docker-registry <regcred> --docker-server=<your-registry-server> \
   --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> \
   -n <your-namespace> 
   ```
   where:
   * `<regcred>` should be quay-regsecret
   * `<your-registry-server>` is quay.io
   * `<your-name>` is your quay.io username 
   * `<your-pword>` is your quay.io password  
   * `<your-email>` is your email address as used to retrieve the quay.io credentials
   
1. Create the `edb-helm` service account in the namespace to run the pods securely using the following command:
   ```
   kubectl apply -f setup/service-account.yaml -n <your-namespace> 
   ```

1. (For OpenShift), assign the privileges defined in the security context constraint to the `edb-helm` service account by using the following command:
   ```
   oc adm policy add-scc-to-user edb-scc -z edb-helm -n <your-namespace>

 
## Deploying with Helm

Several example values.yaml files are provided. Please refer to `charts/postgresql/values.yaml` for a list of all options as well as a description of how they work. Use the following command to list all available examples:
```
ls examples/
```
To use the charts with the provided sample values files, you must:
* **Accept the [End User License Agreement (EULA)](https://www.enterprisedb.com/limited-use-license) by changing the default for `acceptEULA` from No to Yes**
* Make other changes to the sample values as desired

The following examples deploy PostgreSQL as a stateful set with a single replica.  The StatefulSet chart is configured with 1 replica by default and is not shown in the values.yaml examples.  Overriding the number of replicas to be greater than 1 will not achieve data redundancy; it will create two standalone instances each with unique data.


### Deploying with default settings

Run one of the following commands depending on the preferred distribution:

* PostgreSQL

   ```
   helm install postgres12 charts/postgresql \
   -f examples/values-pg-v12.yaml --set acceptEULA=Yes \
   -n <your-namespace>
   ```

* EDB Postgres Advanced Server
   ```
   helm install epas12 charts/postgresql \
   -f examples/values-epas-v12.yaml --set acceptEULA=Yes \
   -n <your-namespace>
   ```
      
### Deploying with a secret for PostgreSQL superuser credentials

1. Create a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/) for the credential of the PostgreSQL superuser:
   ```
   kubectl create secret generic example-pg-secret \
   --from-literal=pgUser=<example-pg-user> \
   --from-literal=pgPassword=<example-pg-password> -n <your-namespace>
   ```
1. Run one of the following commands depending on the preferred distribution:
   * PostgreSQL
     ```
     helm install postgres12 charts/postgresql \
     -f examples/values-pg-v12-secret.yaml --set acceptEULA=Yes \
     -n <your-namespace>
     ```
     
  * EDB Postgres Advanced Server
    ```
    helm install epas12 charts/postgresql \
    -f examples/values-epas-v12-secret.yaml --set acceptEULA=Yes \
    -n <your-namespace>
    ```

### Deploying with custom postgresql.conf settings

1. Create a configmap with custom postgresql settings as shown in the example below:
   ```
   kubectl apply -f setup/configmap.yaml -n <your-namespace> 
   ```

1. Run one of the following commands depending on the preferred distribution:
   * PostgreSQL
     ```
     helm install postgres12 charts/postgresql \
     -f examples/values-pg-v12-custom.yaml --set acceptEULA=Yes \
     -n <your-namespace>
     ```
     
  * EDB Postgres Advanced Server
    ```
    helm install epas12 charts/postgresql \
    -f examples/values-epas-v12-custom.yaml --set acceptEULA=Yes \
    -n <your-namespace>
    ```  

## Verifying successful deployment

Once the container has been deployed, run the following command to verify the status of the pods:
```
kubectl get pods -n <your-namespace> 
```
If the deployment is successful, the output of the previous command will show the pod as ready and a status of `Running` as follows depending on distribution deployed:

    ```
    NAME                               READY   STATUS    RESTARTS   AGE
    edb-pg-12-0                        1/1     Running   0          2m7s
    edb-epas-12-0                      1/1     Running   0          3m3s
    ```

## Using PostgreSQL

After verifying successful deployment to Kubernetes via Helm, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.

### Accessing the deployment using kubectl

1. Open a shell into the container:

   * PostgreSQL
     ```
     kubectl exec -it edb-pg-12-0 -n <your-namespace> -- bash
     ```
   * EDB Postgres Advanced Server
     ```
     kubectl exec -it edb-epas-12-0 -n <your-namespace> -- bash
     ```
1. Log into the database:
   ```
   $PGBIN/psql -d postgres -U enterprisedb
   ```
1. Run sample queries:
   ```
   edb=# select version();
   edb=# create table mytable1(var1 text);
   edb=# insert into mytable1 values ('hi from postgres 12');
   edb=# select * from mytable1;
   ```
1. (For EDB Postgres Advanced Server), check compatibility with Oracle database:   
   ```
   postgres=# show db_dialect;
   ```
   ```
   db_dialect
   -------------
   redwood
   (1 row)
   ```
   The value will be `postgres` if the database is running compatibility with PostrgreSQL database (non-redwood).

   
### Accessing the deployment from a client application

1. Forward a local port to the database port in the container depending on distribution deployed:

   * PostgreSQL
     ```
     kubectl port-forward edb-pg-12 <local-port>:5432 -n <your-namespace>
     ```
   * EDB Postgres Advanced Server
     ```
     kubectl port-forward edb-epas-12 <local-port>:5444 -n <your-namespace>
     ```

1. Access the PostgreSQL database from a client application. For example, pgAdmin can use the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step.

## Deleting Kubernetes Objects

1. The following commands delete the Helm charts installed with the deployments: 
   * PostgreSQL 
     ```
     helm delete postgres12 -n <your-namespace>
     ```
   * EDB Postgres Advanced Server
     ```
     helm delete epas12 -n <your-namespace>
     ```
     
1. The following commands delete any PVC's created with your deployments:
   * PostgreSQL
     ```
     kubectl delete pvc data-edb-pg-12-0 -n <your-namespace>
     kubectl delete pvc wal-edb-pg-12-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-pg-12-0 -n <your-namespace>
     ```
   * EDB Postgres Advanced Server
     ```
     kubectl delete pvc data-edb-epas-12-0 -n <your-namespace>
     kubectl delete pvc wal-edb-epas-12-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-epas-12-0 -n <your-namespace>
     ```

1. If the same namespace will be used again for deployments, skip this step. Otherwise, the following commands delete installed prerequisites:
   ```
   kubectl delete secret quay-regsecret -n <your-namespace>
   kubectl delete secret example-pg-secret -n <your-namespace>
   kubectl delete -f setup/service-account.yaml -n <your-namespace>
   kubectl delete -f setup/configmap.yaml -n <your-namespace>
   ```
