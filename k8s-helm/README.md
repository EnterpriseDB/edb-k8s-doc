# Helm
Some customers may prefer to deploy EDB containers using Helm rather than using Docker, the Operator, or the native Kubernetes CLI.  Sample commands and examples are provided for deploying PostgreSQL and EDB Postgres Advanced Server container images to Kubernetes as a StatefulSet or single pod.

## Prerequisites

Complete all of the prerequisites before using the Helm charts. The prerequisites are provided in the sample files. You can modify the sample files as required by your deployment. 
1. Install [Helm 3](https://helm.sh/docs/intro/install/).
1. Obtain access to an OpenShift 4.4 Kubernetes cluster.   
1. Obtain access to an existing namespace or create a new namespace to hold the deployment using the following command:
   ```
   kubectl create ns <your-namespace>
   ```
   For more information, refer to the [Creating a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace) documentation provided by Kubernetes.
   
1. Create a secret for pulling images from quay.io in the namespace; the secret will be used when deploying container images:
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
   
   For more information on why and how to use secrets, refer to [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) documentation provided by Kubernetes.
   
1. Create the `edb-helm` service account in the namespace to run the pods securely using the following command:
   ```
   kubectl apply -f setup/service-account.yaml -n <your-namespace> 
   ```
1. (For StatefulSet examples), create a configmap to override the default postgres.conf settings in the namespace.  The example configmap is only showcasing the functionality in StatefulSet examples provided; however, a custom postgres.conf can be provided for single pod or StatefulSet deployments if desired. 
   ```
   kubectl apply -f setup/configmap.yaml -n <your-namespace> 
   ``` 
1. (For OpenShift), assign the privileges defined in the security context constraint to the `edb-helm` service account by using the following command:
   ```
   oc adm policy add-scc-to-user edb-scc -z edb-helm -n <your-namespace>
   ```

 
## Deploying with Helm

Several example values.yaml files are provided. Please refer to `charts/postgresql/values.yaml` for a list of all options as well as a description of how they work. Use the following command to list all available examples:
```
ls examples/
```
To use the charts with the provided sample values files, you must:
* **Accept the [End User License Agreement (EULA)](https://www.enterprisedb.com/limited-use-license) by changing the default for `acceptEULA` from No to Yes**
* Make other changes to the sample values as desired


### Deploying a Single pod

For deploying a single pod, run one of the following commands depending on the preferred distribution:
* PostgreSQL v12: 
  ```
  helm install postgres12-single charts/postgresql \
  -f examples/values-pg-v12-single.yaml --set acceptEULA=Yes \
  -n <your-namespace>
  ```
* Advanced Server v12 compatibility with Oracle: 
  ```
  helm install epas12-single charts/postgresql \
  -f examples/values-epas-v12-redwood-single.yaml --set acceptEULA=Yes \
  -n <your-namespace>
  ```

### Deploying a StatefulSet

For deploying a StatefulSet, run one of the following commands dependinig on the preferred distribution:
* PostgreSQL v12: 
  ```
  helm install postgres12-statefulset charts/postgresql \
  -f examples/values-pg-v12-statefulset.yaml --set acceptEULA=Yes \
  -n <your-namespace>
  ```
* Advanced Server v12 with compatibility with Oracle: 
  ```
  helm install epas12-statefulset charts/postgresql \
  -f examples/values-epas-v12-redwood-statefulset.yaml --set acceptEULA=Yes \
  -n <your-namespace>
  ```

**Note:** The StatefulSet chart is configured with 1 replica by default and is not shown in the values.yaml examples.  Overriding the number of replicas to be greater than 1 will not achieve data redundancy; it will create two standalone instances each with unique data.  

## Verification

Once the container has been deployed, run the following command to verify the status of the pods:
```
kubectl get pods -n <your-namespace> 
```
If the deployment is successful, the output of the previous command for EDB Postgres Advanced Server v12 will show all pods ready, and a status of Running as follows:

    NAME                                 READY   STATUS    RESTARTS   AGE
    edb-epas-v12-redwood-single          1/1     Running   0          2m7s
    edb-epas-v12-redwood-statefulset-0   1/1     Running   0          3m12s

## Using PostgreSQL

After verifying successful deployment to Kubernetes via Helm, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.

### Accessing the deployment using kubectl

1. Open a shell into the container:

   * Single Pod:
     ```
     kubectl exec -it edb-epas-v12-redwood-single -n <your-namespace> -- bash
     ```
   * StatefulSet:
     ```
     kubectl exec -it edb-epas-v12-redwood-statefulset -n <your-namespace> -- bash
     ```
1. Log into the database:
   ```
   $PGBIN/psql -d postgres -U enterprisedb
   ```
1. Run sample queries:
   ```
   edb=# select version();
   edb=# create table mytable1(var1 text);
   edb=# insert into mytable1 values ('hi from epas 12');
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

1. Forward a local port to the database port in the container:
   ```
   kubectl port-forward edb-epas-v12-redwood-single <local-port>:5444 -n <your-namespace> 
   ```
1. Access the Postgres database from a client application. For example, pgAdmin can use the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step.

## Deleting Kubernetes Objects

1. The following commands delete the Helm charts installed with the deployments: 
   * PostgreSQL v12: 
     ```
     helm delete postgres12-single -n <your-namespace>
     helm delete postgres12-statefulset -n <your-namespace>
     ```
   * Advanced Server v12 with compatibility with Oracle database:
     ```
     helm delete epas12-single -n <your-namespace>
     helm delete epas12-statefulset -n <your-namespace>
     ```
     
1. The following commands delete any PVC's created with StatefulSet deployments:
   * PostgreSQL v12: 
     ```
     kubectl delete pvc data-edb-pg-v12-statefulset-0 -n <your-namespace>
     kubectl delete pvc wal-edb-pg-v12-statefulset-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-pg-v12-statefulset-0 -n <your-namespace>
     ```
   * Advanced Server v12 with compatibility with Oracle database:
     ```
     kubectl delete pvc data-edb-epas-v12-redwood-statefulset-0 -n <your-namespace>
     kubectl delete pvc wal-edb-epas-v12-redwood-statefulset-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-epas-v12-redwood-statefulset-0 -n <your-namespace>
     ```

1. If the same namespace will be used again for deployments, skip this step. Otherwise, the following commands delete installed prerequisites: 
   ```
   kubectl delete secret quay-regsecret -n <your-namespace>
   kubectl delete -f setup/service-account.yaml -n <your-namespace> 
   kubectl delete -f setup/configmap.yaml -n <your-namespace> 
   ```
