# EDB-HELM
This repository contains Helm charts and examples for deploying PostgreSQL and EDB Postgres Advanced Server container images to Kubernetes as a statefulset or single pod.

## Prerequisites
Before using these Helm charts, please ensure the prerequisite requirements have been met.  Sample files are provided in the examples folder for completing the prerequisites. Change the sample files as needed to meet environment specific requirements.
1. Access to a Kubernetes cluster.   
2. Access to an existing namespace or create a new namespace to hold the deployment. More information from k8s.io can be found [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace).
   ```
   kubectl create ns <your-namespace>
   ```
3. A secret for pulling images from quay.io exists in the namespace that will be used for deployment.  More information from k8s.io can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line).
   ```
   kubectl create secret docker-registry <regcred> --docker-server=<your-registry-server> \
   --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> \
   -n <your-namespace> 
   ```
   * `<regcred>` should be quay-regsecret
   * `<your-registry-server>` is quay.io
   * `<your-name>` is your quay.io username 
   * `<your-pword>` is your quay.io password  
   * `<your-email>` is your email address as used to retrieve the quay.io credentials
   
4. A service account exists for running the pods securely in the namespace that will be used for deployment. 
   ```
   kubectl apply -f examples/service-account.yaml -n <your-namespace> 
   ```
5. If deploying the statefulset examples provided by EDB, a configmap exists in the namespace that will be used for deployment.
   ```
   kubectl apply -f examples/configmap.yaml -n <your-namespace> 
   ``` 
6. If using Openshift, ensure that the appropriate privileges or security context constraints have been created and assigned. More information on SCC can be found in Openshift documentation. A sample SCC with the required permission is included for reference. It assumes the edb service account is being used.  Change as needed.
   ```
   kubectl apply -f examples/scc.yaml
   oc adm policy add-scc-to-user edb-helm-scc -z edb-helm 
   ```  

## Deploying

Several sample values.yaml files are provided. Please refer to charts/postgresql/values.yaml for a list of all options as well as a description of how they work. Use the following command to list all available samples:
```
ls charts/postgresql/
```
To use the charts with the provided sample values files:
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

For deploying a statefulset, run one of the following commands dependinig on the distribution preferred:
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
Verify that the pods have successfully deployed
```
kubectl get pods
```
The output of the command should look similar to the following if EDB Postgres Advanced Server v11 containers were deployed successfully:

    NAME                               READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-single        1/1     Running   0          2m7s
    edb-epas-v11-redwood-statefulset   1/1     Running   0          3m12s

## Using Postgres

After verifying successful deployment to Kubernetes via Helm, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.
### Access the deployment via kubectl 

1. Open a shell into the container:

   Single Pod:
   ```
   kubectl exec -it edb-epas-v11-redwood-single -- bash
   ```
   StatefulSet:
   ```
   kubectl exec -it edb-epas-v11-redwood-statefulset -- bash
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
### Remote access from a client application

1. Forward a local port to the database port in the container:
   ```
   kubectl port-forward edb-epas-v11-noredwood-single <local-port>:5444
   ```
2. Access the postgres database from a client application, e.g. pgadmin, using the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step
## Cleanup
1. Delete the Helm charts installed for your Postgres deployments. 
```
helm delete postgres11-single
helm delete postgres11-statefulset
helm delete epas11-single
helm delete epas11-statefulset
```
2. Delete any PVC's created for statefulset deployments.
```
kubectl delete pvc data-edb-pg-v11-statefulset-0 wal-edb-pg-v11-statefulset-0 walarchive-edb-pg-v11-statefulset-0
kubectl delete pvc data-edb-epas-v11-redwood-statefulset-0 wal-edb-epas-v11-redwood-statefulset-0 walarchive-edb-epas-v11-redwood-statefulset-0
```

3. Delete prerequisites if necessary. If you plan to reuse the objects in the same namespace, skip this step.
```
kubectl delete secret quay-regsecret
kubectl delete serviceaccount edb-helm
kubectl delete configmap edb-db-custom-config
```
