# k8s-CLI
Some customers may prefer to deploy EDB containers using the native CLI (kubectl or oc) rather than using Docker, Helm, or the Operator.  Sample commands and examples are provided for deploying PostgreSQL and EDB Postgres Advanced Server container images to Kubernetes as a StatefulSet or single pod.

## Prerequisites

Complete all of the prerequisites before deploying using the CLI. The prerequisites are provided in the sample files. You can modify the sample files as required by your deployment. 
1. Obtain access to an OpenShift 4.4 Kubernetes cluster.   
2. Obtain access to an existing namespace or create a new namespace to hold the deployment using the following command:
   ```
   kubectl create ns <your-namespace>
   ```
   For more information, refer to the [Creating a Namespace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace) documentation provided by k8s.io.
3. Create a secret for pulling images from quay.io in the namespace; the secret will be used when deploying container images:
   ```
   kubectl create secret docker-registry <regcred> --docker-server=<your-registry-server> \
   --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> \
   -n <your-namespace> 
   ```
   where
   * `<regcred>` should be quay-regsecret
   * `<your-registry-server>` is quay.io
   * `<your-name>` is your quay.io username 
   * `<your-pword>` is your quay.io password  
   * `<your-email>` is your email address as used to retrieve the quay.io credentials
   For more information, refer to [Creating a Secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line) documentation provided by k8s.io.
4. Create a service account in the namespace to run the pods securely using the following command:
   ```
   kubectl apply -f setup/service-account.yaml -n <your-namespace> 
   ```

5. (For OpenShift), the appropriate privileges and security context constraints must be created and assigned to the service account by using the following commands:
   ```
   kubectl apply -f setup/scc.yaml
   oc adm policy add-scc-to-user edb-cli-scc -z edb-cli 
   ```  
The sample SCC provided includes the required permissions for successful deployment to OpenShift 4.4. It assumes the `edb-cli` service account is being used.  Change the commands and file if a different service account will be used.

## Deploying with CLI (kubectl)
Several yaml files are provided. Please refer to `examples/single_pod_with_comments.yaml` and `examples/statefulset_with_comments.yaml` for a list of all options as well as a descriptions of how they work. Use the following command to list all available examples:
```
ls examples/
```

### Deploying a Single Pod

For deploying a single pod, run one of the following commands depending on the preferred distribution:
* EDB Postgres Advanced Server v11 compatibility with Oracle (redwood mode):
  ```
  kubectl apply -f examples/epas_v11_redwood_single.yaml -n <your-namespace> 
  ```
* Deploy EDB Postgres Advanced Server v11 with custom postgresql.conf settings:
  ```
  kubectl apply -f setup/configmap.yaml -n <your-namespace> 
  kubectl apply -f examples/epas_v11_redwood_single_custom.yaml -n <your-namespace> 
  ```
 * Deploy EDB Postgres Advanced Server v11 with secret containing user credentials:
   ```
   kubectl create secret generic my-pg-secret \
   --from-literal=pgUser=myuser \
   --from-literal=pgPassword=mypassword -n <your-namespace> 
   
   kubectl apply -f examples/epas_v11_redwood_single_secret.yaml -n <your-namespace> 
   ```
  
### Deploying as a StatefulSet

For deploying a StatefulSet, run one of the following commands dependinig on the preferred distribution:
* Deploy EDB Postgres Advanced Server v11 with compability wiht Oracle (redwood mode):
  ```
  kubectl apply -f examples/epas_v11_redwood_statefulset.yaml -n <your-namespace> 
  ```
* Deploy EDB Postgres Advanced Server v11 with custom postgresql.conf settings:
  ```
  kubectl apply -f setup/configmap.yaml -n <your-namespace> 
  kubectl apply -f examples/epas_v11_redwood_statefulset_custom.yaml -n <your-namespace> 
  ```
* Deploy EDB Postgres Advanced Server v11 with secret containing user credentials:
  ```
  kubectl create secret generic my-pg-secret \
    --from-literal=pgUser=myuser \
    --from-literal=pgPassword=mypassword -n <your-namespace> 

  kubectl apply -f examples/epas_v11_redwood_statefulset_secret.yaml -n <your-namespace> 
  ```

**Note:** The StatefulSet is configured with 1 replica by default and is not shown in the yaml examples.  Overriding the number of replicas to be greater than 1 will not achieve data redundancy; it will create two standalone instances each with unique data.  


## Verification

Once the container has been deployed, run the following command to verify the status of the pods:
```
kubectl get pods -n <your-namespace> 
```
If the deployment is successful, the output of the previous command for EDB Postgres Advanced Server v11 will show all pods ready and a status of Running as follows:

    NAME                               READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-single        1/1     Running   0          2m7s
    edb-epas-v11-redwood-statefulset-0 1/1     Running   0          3m12s

## Using PostgreSQL

After verifying successful deployment to Kubernetes via Helm, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.

### Accessing the deployment using kubectl

1. Open a shell into the container:

   * Single Pod:
     ```
     kubectl exec -it edb-epas-v11-redwood-single -n <your-namespace> -- bash
     ```
   * StatefulSet:
     ```
     kubectl exec -it edb-epas-v11-redwood-statefulset-0 -n <your-namespace> -- bash
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
4. Check Redwood Mode (EPAS):   
   ```
   postgres=# show db_dialect;
   ```
   ```
   db_dialect
   -------------
   redwood
   (1 row)
   ```
   
### Accessing the deployment from a client application

1. Forward a local port to the database port in the container:
   ```
   kubectl port-forward edb-epas-v11-noredwood-single <local-port>:5444 -n <your-namespace>
   ```
2. Access the PostgreSQL database from a client application. For example, pgAdmin can use the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step

## Deleting Kubernetes Objects

1. The following commands delete the objects installed with the deployments:
   ```
   kubectl delete -f examples/epas_v11_redwood_single.yaml -n <your-namespace>
   kubectl delete -f examples/epas_v11_redwood_single_custom.yaml -n <your-namespace> 
   kubectl delete -f examples/epas_v11_redwood_single_secret.yaml -n <your-namespace>
   kubectl delete -f examples/epas_v11_redwood_statefulset.yaml -n <your-namespace>
   kubectl delete -f examples/epas_v11_redwood_statefulset_custom.yaml -n <your-namespace>
   kubectl delete -f examples/epas_v11_redwood_statefulset_secret.yaml -n <your-namespace> 
   ```
   
2. The following commands delete any PVC's created with StatefulSet deployments:
   ```
   kubectl delete pvc data-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
   kubectl delete pvc wal-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
   kubectl delete pvc walarchive-edb-epas-v11-redwood-statefulset-0 -n <your-namespace>
   ```

3. If the same namespace will be used again for deployments, skip this step. Otherwise, the following commands delete installed prerequisites:
   ```
   kubectl delete secret quay-regsecret -n <your-namespace>
   kubectl delete secret my-pg-secret -n <your-namespace>
   kubectl delete -f setup/service-account.yaml -n <your-namespace>
   kubectl delete -f setup/configmap.yaml -n <your-namespace>
   ```
