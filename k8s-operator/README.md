# EDB Kubernetes Operator

## Overview

The EDB Operator (edb-operator) simplifies database administration tasks for deploying and managing PostgreSQL and EDB Postgres Advanced Server clusters on Kubernetes. The EDB Operator incorporates domain expertise and years of practical experience for maintaining and configuring PostgreSQL database clusters. 

The EDB Operator can:
* deploy with or without streaming replication
* failover to a standby database node while ensuring a minimum number of defined nodes
* control configuration parameters
* adjust compute resources automatically
* assign metadata tags to a cluster

In summary, the specification for the PostgreSQL or EDB Postgres Advanced Server cluster is provided to the EDB Operator and in turn, the operator provisions compute resources and the database pods while continuously ensuring the cluster runs with the provided specification.

## Tested Platforms 

### OS Images
* Red Hat Universal Base Image
   * ubi7

### PostgreSQL Distributions
* PostgreSQL
  * v10-12
* EDB Postgres Advanced Server compatibility with Oracle (redwood)
  * v10-12
* EDB Postgres Advanced Server compatibility with PostgreSQL (non-redwood)
  * v10-12

### Platforms
* OpenShift Container Platform 4.5

## Prerequisites

### Cluster Prerequisites
1. Obtain access to a Kubernetes cluster.

1. Create a cluster level storage class to map a platform storage provisioner to `edb-storageclass`. Each platform hosting Kubernetes clusters has their own storage provisioners that are used for persistent volume claims; mapping them to a common name simplifies the deployment examples provided.  The following commands (and example yaml) can be used to define `edb-storageclass` for common public cloud platforms:

   * AWS EBS `kubectl apply -f setup/storage-class-aws-ebs.yaml`

   * GCE Persistent Disk `kubectl apply -f setup/storage-class-gce-pd.yaml`

   * Azure Disk `kubectl apply -f setup/storage-class-azure-disk.yaml`
   
   For additional examples, refer to the [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) documentation provided by Kubernetes.
   
1. Deploy the customer resource definitions (CRD) by running the following command:
   ```
   kubectl apply -k setup/crds/.
   ```

1. (For OpenShift) Create a Security Context Constraint (SCC) which includes the required permissions for successful deployment to OpenShift 4.4 or later by using the following command:
   ```
   kubectl apply -f setup/scc.yaml
   ```
   
### Namespace Prerequisities   
1. Obtain access to an existing namespace or create a new namespace to hold the deployment using the following command:
   ```
   kubectl create ns <your-namespace>
   ```

1. Modify the database login credentials by editing the literal values in [setup/kustomization.yaml](setup/kustomization.yaml)

1. Deploy the Operator by running the following command:
   ```
   kubectl apply -k setup/. -n <your-namespace>
   ```
1. (For OpenShift), assign the privileges defined in the security context constraint to the `edb-operator` service account by using the following command:
   ```
   oc adm policy add-scc-to-user edb-scc -z edb-operator -n <your-namespace>
   ```

## Design Overview

The EDB Operator is a full solution Operator that can be used for development and operations of stateful objects at scale. 


### Standalone Instance  

The EDB Operator supports deploying standalone PostgreSQL instances with no replicaton by setting the value of `enable:` to `false` under the highAvailability in the specification as shown in the following example:   

```
 highAvailability:
   enable: false
```

When using this specification, the `clusterSize` value determines the number of decoupled (standalone) instances to launch. Setting a clusterSize to 3 would create 3 standalone PostgreSQL instances:
```
 clusterSize: 3
```

### High Availability Cluster  

The EDB Operator also supports deploying a high availability (HA) cluster of multiple PostgreSQL instances with replicaton by setting the value of `enable:` to `true` under the highAvailability specification as shown in the following example:   

```
 highAvailability:
   enable: true
```

When using this specification, the `clusterSize` value determines the total number of instances to launch that will be considered an HA cluster. Setting a clusterSize to 5 would create 1 primary and 4 replica PostgreSQL instances using streaming replication:
```
 clusterSize: 5
```
In addition to deploying PostgreSQL instances and enabling streaming replication, the HA setup includes Stolon which uses a cluster-aware proxy and sentinel(s) that constantly communicate to keep the desired cluster state. Streaming replication health and maintenance operations are performed automatically.

#### Proxy

All connections to the HA cluster are handled by a proxy to ensure connections to the current Primary. The proxy provides fencing and will close databases connections to an old Primary and direct new database connections to a newly promoted Primary. 


#### Sentinel(s) 

Sentinel(s) act as watchers to keep the state of the HA cluster as defined and are responsible for monitoring the HA cluster, detecting failures, and initiating failovers and re-joins where appropriate. The state of the HA cluster is tracked and stored in a state cluster view configmap. 

Storing the state in a configmap, gives the operator the ability to change the state of the cluster by patching the changes to the configmap. Functionality such as reconfiguring a database and forcing a failover can be done by patching the configmap.

## Deploying with the Operator


### Deploying standalone PostgreSQL instances

   * PostgreSQL 
     ```
     kubectl apply -f examples/pg-12-no-ha.yaml -n <your-namespace>
     ```  
     
   * EDB Postgres Advanced Server (EPAS)  
     ```
     kubectl apply -f examples/epas-12-no-ha.yaml -n <your-namespace>
     ```

### Deploying high availability PostgreSQL cluster (multiple instances)

   * PostgreSQL
     ```
     kubectl apply -f examples/pg-12-ha.yaml -n <your-namespace>
     ```
     
   * EDB Postgres Advanced Server (EPAS)  
     ```
     kubectl apply -f examples/epas-12-ha.yaml -n <your-namespace>
     ```

## Verification

After deploying with the EDB Operator, run the following command to verify the status of the pods:
```
$ kubectl get deploy -n <your-namespace>
```
If the deployment is successful, the output of the command for an HA specification of EDB Postgres Advanced Server v12 will show the number of cluster-aware proxies (edb-epas-12-proxy) and sentinels (edb-epas-12-sentinel) matching the clusterSize requested:

```
NAME                  READY  UP-TO-DATE   AVAILABLE   AGE
edb-epas-12-proxy     5/5    5            5           4d19h
edb-epas-12-sentinel  5/5    5            5           4d19h
edb-operator          2/2    2            2           4d19h
```
 
In addtion after the deployment, run the following command to verify the status of the pods in the cluster:
```
$ kubectl get pod -n <your-namespace>
```
If the deployment is successful, the output of the command for an HA specification of EDB Postgres Advanced Server v12 will show all pods ready and a status of Available status as follows:
```
NAME                                        READY   STATUS    RESTARTS  AGE
edb-epas-12-ha-0                            1/1     Running   0         5d21h
edb-epas-12-ha-1                            1/1     Running   0         5d21h
edb-epas-12-ha-2                            1/1     Running   0         5d21h
edb-epas-12-ha-proxy-858f6bb967-bm97j       1/1     Running   0         5d21h
edb-epas-12-ha-proxy-858f6bb967-j6q7v       1/1     Running   0         5d21h
edb-epas-12-ha-proxy-858f6bb967-ntnfh       1/1     Running   0         5d21h
edb-epas-12-ha-sentinel-54fff448c5-dl9bc    1/1     Running   0         5d21h
edb-epas-12-ha-sentinel-54fff448c5-mwh2d    1/1     Running   0         5d21h
edb-epas-12-ha-sentinel-54fff448c5-nn4fx    1/1     Running   0         5d21h
edb-operator-6b4d4494c9-hwpr5               1/1     Running   0         5d21h
edb-operator-6b4d4494c9-xwkfp               1/1     Running   0         5d21h
```

## Using PostgreSQL

After verifying successful deployment to Kubernetes, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.

### Accessing the deployment using kubectl

1. Open a shell into the container:

   * Standalone instances (PostgreSQL and EPAS)
     ```
     kubectl exec -it edb-pg-12-0 -n <your-namespace> -- bash

     kubectl exec -it edb-epas-12-0 -n <your-namespace> -- bash
     ```
   
   * High availability cluster (PostgreSQL and EPAS) 
     ```
     kubectl exec -it edb-pg-12-ha-0 -n <your-namespace> -- bash

     kubectl exec -it edb-epas-12-ha-0 -n <your-namespace> -- bash
     ```
1. Log into the database:

   * Standalone instances (PostgreSQL and EPAS)
      ```
      $PGBIN/psql -d postgres -U enterprisedb -h edb-pg-12 -p 5432

      $PGBIN/psql -d postgres -U enterprisedb -h edb-epas-12 -p 5444
      ```

   * High availability cluster (PostgreSQL and EPAS)
      ```
      $PGBIN/psql -d postgres -U enterprisedb -h edb-pg-12-ha-proxy-service -p 5432

      $PGBIN/psql -d postgres -U enterprisedb -h edb-epas-12-ha-proxy-service -p 5444
      ```
   
### Accessing the deployment from a client application

1. Forward a local port to the database port in the container depending on distribution deployed:

   * Standalone instances (PostgreSQL and EPAS)
      ```
      kubectl port-forward edb-pg-12 <local-port>:5432 -n <your-namespace>

      kubectl port-forward edb-epas-12 <local-port>:5444 -n <your-namespace>
      ```
      
   * High availability cluster (PostgreSQL and EPAS)
      ```
      kubectl port-forward edb-pg-12-ha-proxy-service <local-port>:5432 -n <your-namespace>

      kubectl port-forward edb-epas-12-ha-proxy-service <local-port>:5444 -n <your-namespace>
      ```

1. Access the PostgreSQL database from a client application. For example, pgAdmin can use the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step.

## Configuration

### Compatiblity with Oracle vs Compatiblity with PostgreSQL   

EDB Postgres Advanced Server can be deployed as either compatibility with Oracle (redwood) or compatibility with PostgreSQL (no redwood). For more information about compatibility with Oracle database, refer to [EDB](https://www.enterprisedb.com/postgres-tutorials/how-run-postgres-oracle-compatibility-mode) documentation.

* Compatibility with Oracle (default)
  ```
  noRedwoodCompat: false
  ```
* Compatiblity with PostgreSQL 
  ```
   noRedwoodCompat: true
  ```

### System Resources  

The amount of CPU/Memory/Disk is configurable when deploying.  Initial allocations and maximum allocations are both specificied.

```
 databaseMemoryLimit: "2Gi"
 databaseMemoryRequest: "1Gi"
 databaseCPULimit: "1000m"
 databaseCPU: "50m"
 databaseStorageRequest: "5Gi"
```

### Custom PostgreSQL Parameters 

The EDB Operator maintains a desired configuration which can be managed programmatically by keeping PostgreSQL parameters in a specification. This approach ensures the PostgreSQL parameters for each instance in the HA cluster are the same. 

To modify PostgreSQL parameter values, update 'primaryConfig' in the specification as shown in the [examples/pg-12-ha-customlabels.yaml](examples/pg-12-ha-customlabels.yaml) example provided where the max_connections is overridden to 150: 
```
 primaryConfig:
   max_connections: "150"
```

Apply the updated specification to Kubernetes and the operator will ensure parameter changes are made on each node if they do not require a restart: 
```
kubectl apply -f examples/pg-12-customlabels.yaml -n <your-namespace>
```

**Note:** The following parameters, if defined in the cluster specification, will be ignored since they are managed by Stolon and cannot be defined by the user:
```
listen_addresses
port
hot_standby
wal_keep_segments
wal_log_hints
hot_standby
synchronous_standby_names
max_replication_slots
max_wal_senders
unix_socket_directories
```

## Using your Deployment

_All steps assume user has access to the Openshift GUI and kubectl in the terminal_


### Verify custom settings were applied 

*   Enter pod shell in the Openshift GUI
*   Login to the desired database
*   Run `SELECT * FROM pg_settings WHERE name=’<value to check>’`
*   Compare the boot_val to the reset_val, where the reset_val should be your custom setting


### (For EDB Postgres Advanced Server), check compatibility with Oracle database:
*   Enter pod shell
*   Login to the desired database
*   Run `show db_dialect`
*   For redwood mode, the output should be “redwood”, otherwise it should be “postgres”

### (For HA deployment) check whether a database is Primary or Standby:

*   Enter the desired pods logs
*   If the pod is Primary, the logs will indicate every cycle that it is Primary

### Change the number of databases in a deployment 

*   Edit the YAML to adjust the clusterSize setting to the desired number using the command line in the directory where the deployment’s YAML is located 
*   Run `kubectl apply -f <name_of_yaml_file> -n <your-namespace>`

### Verify failover from Primary in a High Availability deployment 

*   Identify which pod in the HA deployment is currently Primary
*   Terminate the Primary pod
*   View the logs for all Secondary pods in the deployment and wait for one to begin reporting as Primary


## Deleting Kubernetes Objects

### Delete a database deployment from a namespace 

*   From the command line (in the directory containing the deployment’s yaml), run: `kubectl delete -f <name_of_yaml_file> -n <your-namespace>`
*   After all pods for the deployment have been terminated, remove the associated PVCs for each pod that have the same name

### Delete the operator from a namespace (infrequent)

*   Delete the objects created in the 'operator' directory based on kustomization.yaml using the following command: 
    ```
    kubectl delete -k setup/. -n <your-namespace>
    ```
*   After all pods have been terminated, remove the associated PVCs using the following command:
    ```
    kubectl delete pvc -l owner=edb-operator -n <your-namespace>
    ``` 
*  In some instances, the configmap created by the operator may not get deleted when the operator is deleted.  Ensure the configmap has been deleted using the following command:    
   ```
   kubectl get configmap -l owner=edb-operator -n <your-namespace>
   ```
*  If the configmap still exists, remove it using the following commands:
   ```
   kubectl patch $(kubectl get configmap -o name -l owner=edb-operator -n <your-namespace>) -p '{"metadata":{"finalizers":null}}' -n <your-namepace>
   kubectl delete configmap  -l owner=edb-operator -n <your-namespace>
   ```


## Debugging

### Useful Commands

* Check current state of a k8s object:
   ```
   kubectl describe pod edb-epas-12-ha-0 -n <your-namespace>
   
   ```
* Check logs of deployed container:
   ```
   kubectl logs edb-epas-12-ha-0 -n <your-namespace>
   
   ```
* Enable application debugging of container by setting the `podDebug` property to `true` in the deployment yaml:
   ```
       podDebug: "true"
   
   ```
* Get a dump of application (database) logs of deployed container:
   ```
   kubectl cp edb-epas-12-ha-0:/var/lib/edb/data/postgres/log ./ -n <your-namespace>
   
   ```



### Sample Scenarios

#### Pod in `ImagePullBackOff` status

In this scenario, output of `kubectl get pods -n <your-namespace>` shows the following output:

```
NAME                           READY   STATUS              RESTARTS   AGE
edb-epas-12-ha-0               0/1     ErrImagePull        0          26s
edb-epas-12-ha-0               0/1     ImagePullBackOff    0          27s
```

Debug Steps:

1. Run the command `kubectl describe pod edb-epas-12-ha-0 -n <your-namespace>` to find the image name. Sample output shown below:

   ```
   Containers:
     edb:
       Container ID:
       Image:         quay.io/edb/postgres-advanced-server-12:latest

   ...
   ...

   Events:
     Type     Reason            Age        From                                               Message
     ----     ------            ----       ----                                               -------       


     Warning  Failed            3m38s      kubelet, ip-10-0-160-9.us-east-2.compute.internal  Failed to pull image "quay.io/edb/postgres-advanced-server-12:latest": [rpc error: code = Unknown desc = unable to retrieve auth token: invalid username/password: unauthorized: Invalid Username or Password, rpc error: code = Unknown desc = Error reading manifest latest in quay.io/edb/postgres-advanced-server-12: unauthorized: access to the requested resource is not authorized]
   ```

1. Verify that you are able to download the image  `quay.io/edb/postgres-advanced-server-12:latest` using your quay.io registry credentials:
   ```
   docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>

   docker pull quay.io/edb/postgres-advanced-server-12:latest
   ```

1. If the above step is unsuccessful contact EDB for support. Otherwise, delete and recreate the registry secret `quay-regsecret` with your verified quay.io credentials:

   ```
   kubectl delete secret quay-regsecret -n <your-namespace>

   kubectl create secret docker-registry quay-regsecret --docker-server=quay.io \
   --docker-username=<your-quay.io-username> --docker-password=<your-quay.io-password> --docker-email=<your-email> \
   -n <your-namespace> 
   ```

1. Delete deployment and redeploy


#### Pod in `Pending` status

In this scenario, output of `kubectl get pods -n <your-namespace>` shows the following output:

```
NAME                            READY   STATUS    RESTARTS   AGE
edb-epas-12-ha-0                0/1     Pending   0          53s
```

Debug Steps:

1. Run the command `kubectl describe pod edb-epas-12-ha-0 -n <your-namespace>`. Sample output shown below:

   ```
   Containers:
     edb:
       Container ID:
       Image:         quay.io/edb/postgres-advanced-server-12:latest
   ...
   ...

   Events:
     Type     Reason            Age        From                           Message
     ----     ------            ----       ----                           -------       

       Warning  FailedScheduling  76s (x4 over 2m27s)  default-scheduler  pod has unbound immediate PersistentVolumeClaims (repeated 3 times)
   ```

1. Get details of `edb-storageclass` storage class:
   ```
   kubectl get sc edb-storageclass -o yaml
   ```

   Sample output (for AWS EBS based storage class) shown below if the `edb-storageclass` storage class exists:

   ```
   allowVolumeExpansion: true
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     annotations:
       kubectl.kubernetes.io/last-applied-configuration: |
         {"allowVolumeExpansion":true,"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"false"},"name":"edb-storageclass"},"parameters":{"encrypted":"true","type":"gp2"},"provisioner":"kubernetes.io/aws-ebs","reclaimPolicy":"Delete","volumeBindingMode":"Immediate"}
       storageclass.kubernetes.io/is-default-class: "false"
     creationTimestamp: "2020-09-01T19:28:02Z"
     name: edb-storageclass
     resourceVersion: "100235187"
     selfLink: /apis/storage.k8s.io/v1/storageclasses/edb-storageclass
     uid: 59f4a541-20bd-4593-a8e8-5a972cd611bb
   parameters:
     encrypted: "true"
     type: gp2
   provisioner: kubernetes.io/aws-ebs
   reclaimPolicy: Delete
   volumeBindingMode: Immediate
   ```

1. If the storage class exists, verify the `provisioner` is correct for your environment. Otherwise, create the storage class based on the provisioner for your environment as described in the [Prerequisites](#prerequisites) section.

1. Delete deployment and redeploy
