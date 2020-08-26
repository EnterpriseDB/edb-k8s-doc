# EDB-HELM
This repository contains Helm charts and examples for deploying PostgreSQL and EDB Postgres Advanced Server container images to Kubernetes as a statefulset or a single pod.

## Prerequisites
Complete all of the prerequisites before using the Helm Charts. The prerequisites are provided in the sample files. You can modify the sample files as required by your deployment. 
1. Obtain access to a Kubernetes cluster.   
2. Obtain access to an existing namespace or create a new namespace to hold the deployment using the following command:
   ```
   kubectl create ns <your-namespace>
   ```
   For more information, refer to the [Creating a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace) documentation provided by k8s.io.
3. Create a secret for pulling images from quay.io in the namespace; the secret will used when deploying container images:
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
   For more information, refer to [Creating a Secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line) documentation provided by k8s.io.
4. Create a service account in the namespace to run the pods securely using the following command:
   ```
   kubectl apply -f examples/service-account.yaml -n <your-namespace> 
   ```
5. Create a configmap in the namespace to deploy the statefulset examples provided by EDB; a configmap will be required for any deployment overriding default postgres.conf settings.
   ```
   kubectl apply -f examples/configmap.yaml -n <your-namespace> 
   ``` 
6. (For Openshift), the appropriate privileges and security context constraints must be created and assigned using the following commands:
   ```
   kubectl apply -f examples/scc.yaml
   oc adm policy add-scc-to-user edb-helm-scc -z edb-helm 
   ```
   The sample SCC provided includes the required permissions for successful deployment to OpenShift 4.4. It assumes the `edb-helm` service account is being used.  Change the commands and file if a different service account will be used.
   
   For more information on SCC, refer to Openshift documentation. 
 
## Deploying

Several sample values.yaml files are provided. Please refer to charts/postgresql/values.yaml for a list of all options as well as a description of how they work. Use the following command to list all available samples:
```
ls charts/postgresql/
```
To use the charts with the provided sample values files, you must:
* **Accept the [End User License Agreement (EULA)](https://www.enterprisedb.com/limited-use-license) by changing the default for `acceptEULA` from No to Yes**
* Make other changes to the sample values as desired


### Deploying a Single pod
For deploying a single pod, run one of the following commands depending on the distribution preferred:
* PostgreSQL v11: 
  ```
  helm install postgres11-single charts/postgresql \
  -f charts/postgresql/values-pg-v11-single.yaml \
  -n <your-namespace>
  ```
* Advanced Server v11 compatibility with Oracle: 
  ```
  helm install epas11-single charts/postgresql \
  -f charts/postgresql/values-epas-v11-redwood-single.yaml \
  -n <your-namespace>
  ```

### Deploying a Statefulset

For deploying a statefulset, run one of the following commands dependinig on the preferred distribution:
* PostgreSQL v11: 
  ```
  helm install postgres11-statefulset charts/postgresql \
  -f charts/postgresql/values-pg-v11-statefulset.yaml \
  -n <your-namespace>
  ```
* Advanced Server v11 with compatibility with Oracle: 
  ```
  helm install epas11-statefulset charts/postgresql \
  -f charts/postgresql/values-epas-v11-redwood-statefulset.yaml \
  -n <your-namespace>
  ```

Note: statefulsets may be scaled greater than 1 but will not have streaming replication enabled or availability beyond that provided by the Kubernetes cluster without implementing database cluster management solutions such as Stolon, Patroni, etc

## Verification
Once the container has been deployed, run the following command to verify the status of the pods:
```
kubectl get pods -n <your-namespace> 
```
If the deployment is successful, the output of the previous command for EDB Postgres Advanced Server v11 will show all pods ready and a status of Running as follows:

    NAME                               READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-single        1/1     Running   0          2m7s
    edb-epas-v11-redwood-statefulset   1/1     Running   0          3m12s

## Using Postgres

After verifying successful deployment to Kubernetes via Helm, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.
### Accessing the deployment using kubectl

1. Open a shell into the container:

   * Single Pod:
     ```
     kubectl exec -it edb-epas-v11-redwood-single -n <your-namespace> -- bash
     ```
   * StatefulSet:
     ```
     kubectl exec -it edb-epas-v11-redwood-statefulset -n <your-namespace> -- bash
     ```
2. Log into the database:
   ```
   $PGBIN/psql -d postgres -U enterprisedb
   ```
3. Run sample queries:
    ```
    edb=# select version();
    edb=# create table mytable1(var1 text);
    edb=# insert into mytable1 values ('hi from epas 11');
    edb=# select * from mytable1;
    ```
### Accessing the deployment from a client application

1. Forward a local port to the database port in the container:
   ```
   kubectl port-forward edb-epas-v11-redwood-single -n <your-namespace> <local-port>:5444
   ```
2. Access the Postgres database from a client application. For example, pgAdmin can use the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step
## Deleting Kubernetes Objects
1. The following commands delete the Helm charts installed with the deployments: 
   * PostgreSQL v11: 
     ```
     helm delete postgres11-single -n <your-namespace>
     helm delete postgres11-statefulset -n <your-namespace>
     ```
   * Advanced Server v11 with compatibility with Oracle:
     ```
     helm delete epas11-single -n <your-namespace>
     helm delete epas11-statefulset -n <your-namespace>
     ```
2. The following commands delete any PVC's created with statefulset deployments:
   * PostgreSQL v11: 
     ```
     kubectl delete pvc data-edb-pg-v11-statefulset-0 -n <your-namespace>
     kubectl delete pvc wal-edb-pg-v11-statefulset-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-pg-v11-statefulset-0 -n <your-namespace>
     ```
   * Advanced Server v11 with compatibility with Oracle:
     ```
     kubectl delete pvc data-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
     kubectl delete pvc wal-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
     kubectl delete pvc walarchive-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
     ```

3. If the same namespace will be used again for deployments, skip this step. Otherwise, the following commands delete installed prerequisites: 
   ```
   kubectl delete secret quay-regsecret -n <your-namespace>
   kubectl delete -f examples/service-account.yaml -n <your-namespace> 
   kubectl delete -f examples/configmap.yaml -n <your-namespace> 
   ```
