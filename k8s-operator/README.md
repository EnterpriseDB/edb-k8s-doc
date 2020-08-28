# EDB Kubernetes Operator

## Overview

The EDB Operator (edb-operator) simplifies database administrator tasks for deploying and managing PostgreSQL and EDB Postgres Advanced Server clusters on Kubernetes. The EDB Operator incorporates domain expertise and years of practical experience for maintaining and configuring Postgres database clusters. 

The EDB Operator provides:
* deployment with or without Streaming Replication
* failover to a standby database node while ensuring a minimum number of defined nodes
* control of configuration parameters
* adjustment of compute resources automatically
* assignment of metadata tags to the cluster

In summary, the specification for the PostgreSQL or EDB Postgres Advanced Server cluster is provided to the EDB Operator and in turn, the operator provisions compute resources and the database pods while continuously ensuring the cluster runs with the provided specification.

## Tested Platforms 

### OS Images
* Red Hat Universal Base Image
   * ubi7

### PostgreSQL Distributions
* PostgreSQL
  * v11
* EDB Postgres Advanced Server compatibility with Oracle (redwood)
  * v11
* EDB Postgres Advanced Server compatibility with PostgreSQL (non-redwood)
  * v11

### Platforms
* OpenShift Container Platform 4.4

## Prerequisites
1. Get your kubectl verison by running `kubectl version --short | grep Client`
1. Setup your image-pull-secret by editing and running the following command for your `kubectl` version

  * for `kubectl` version <1.18.0
```
kubectl create secret docker-registry --dry-run=true edb-operator-pull-secret \
--docker-server=<DOCKER_REGISTRY_SERVER> \
--docker-username=<DOCKER_USER> \
--docker-password=<DOCKER_PASSWORD> \
--docker-email=<DOCKER_EMAIL> -o yaml > operator/pull-secret.yaml
```
   * for `kubectl` version >1.18.0
```
kubectl create secret docker-registry --dry-run=client edb-operator-pull-secret \
--docker-server=<DOCKER_REGISTRY_SERVER> \
--docker-username=<DOCKER_USER> \
--docker-password=<DOCKER_PASSWORD> \
--docker-email=<DOCKER_EMAIL> -o yaml > operator/pull-secret.yaml
```
3. Modify your database login as preferred by editing the literal values in `/operator/kustomization.yaml`
3. Deploy the CRD first by running the following command:
    `kubectl apply -k operator/crds/.`
3. Deploy the Operator by running the following command:
   `kubectl apply -k .`
3. (For OpenShift), add a Security Context Constraint (SCC) to run containers as root or specified UID using the following command:
   `oc adm policy add-scc-to-user edb-operator-scc -z edb-operator`

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
     kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-no-ha.yaml
     ```  
     
   * EDB Postgres Advanced Server (EPAS)  
     ```
     kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-epas-no-ha.yaml
     ```

### Deploying high availability PostgreSQL cluster (multiple instances)

   * PostgreSQL
     ```
     kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-ha.yaml
     ```
     
   * EDB Postgres Advanced Server (EPAS)  
     ```
     kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-epas-ha.yaml
     ```

## Verification

After deploying with the EDB Operator, run the following command to verify the status of the pods:
```
$ kubectl get deploy
```
If the deployment is successful, the output of the command for an HA specification of EDB Postgres Advanced Server v11 will show the number of cluster-aware proxies (edb-epas-11-proxy) and sentinels (edb-epas-11-sentinel) matching the clusterSize requested:

```
NAME               	 READY  UP-TO-DATE   AVAILABLE   AGE
edb-epas-11-proxy  	 5/5 	  5        	   5           4d19h
edb-epas-11-sentinel 5/5 	  5        	   5           4d19h
edb-operator       	 2/2 	  2            2           4d19h
```
 
In addtion after the deployment, run the following command to verify the status of the pods in the cluster:
```
$ kubectl get pod
```
If the deployment is successful, the output of the command for an HA specification of EDB Postgres Advanced Server v11 will show all pods ready and a status of Available status as follows:
```
NAME                                	    READY   STATUS RESTARTS   AGE
edb-epas-11-0                       	    1/1 	   Running   0       5d21h
edb-epas-11-1                       	    1/1 	   Running   0       5d21h
edb-epas-11-2                       	    1/1 	   Running   0      	5d21h
edb-epas-11-3                       	    1/1 	   Running   0      	5d21h
edb-epas-11-4                       	    1/1 	   Running   0  	    5d21h
edb-epas-11-proxy-858f6bb967-bm97j  	    1/1 	   Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-j6q7v  	    1/1 	   Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-ntnfh  	    1/1 	   Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-t6tp9  	    1/1 	   Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-zk29s  	    1/1 	   Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-dl9bc    1/1 	   Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-mwh2d    1/1 	   Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-nn4fx    1/1 	   Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-pdhn8    1/1 	   Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-tll29    1/1 	   Running   0      	5d21h
edb-operator-6b4d4494c9-hwpr5       	    1/1 	   Running   0      	5d21h
edb-operator-6b4d4494c9-xwkfp       	    1/1 	   Running   0      	5d21h
```


## Configuration

### Compatiblity with Oracle vs Compatiblity with PostgreSQL   

EDB Postgres Advanced Server can be deployed as either compatibility with Oracle (redwood) or compatibility with PostgreSQL (noredwood). For more information about compatibility with Oracle database, refer to <add reference>.

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

To modify PostgreSQL parameter values, update 'primaryConfig' in the specification as shown in the [edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml](/`/examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml`) example provided where the max_connections is overriddent to 150: 
```
 primaryConfig:
   max_connections: "150"
```

Apply the updated specification to Kubernetes and the operator will ensure parameter changes are made on each node if they do not require a restart: 
```
kubectl apply -f /examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml
```

**Note:** The following parameters, if defined in the cluster specification, will be ignored since they are managed by stolon and cannot be defined by the user:
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

#### (For HA deployment) check whether a database is Primary or Standby:

*   Enter the desired pods logs
*   If the pod is Primary, the logs will indicate every cycle that it is Primary

### Change the number of databases in a deployment 

*   Edit the YAML to adjust the clusterSize setting to the desired number using the command line in the directory where the deployment’s YAML is located 
*   Run `kubectl apply -f <name_of_yaml_file>`

### Verify failover from Primary in a High Availability deployment 

*   Identify which pod in the HA deployment is currently Primary
*   Terminate the Primary pod
*   View the logs for all Secondary pods in the deployment and wait for one to begin reporting as Primary


## Deleting Kubernetes Objects

### Remove a database deployment from your cluster 

*   From the command line in the directory containing the deployment’s yaml is located: `kubectl delete -f <name_of_yaml_file>`
*   After all of the deployment’s pods have been terminated, remove the associated PVCs for each pod that have the same name

### Delete the operator from your namespace 

*   From the command line, run `examples/kubectl delete -k .`
*   After all pods have been terminated, remove the associated PVCs by running `kubectl delete pvc -l owner=edb-operator`

### Delete the operator from your cluster 

*   From the command line, run `examples/kubectl delete -k operator/crds/.`
*   From the command line, run `examples/kubectl delete -k .`
*   After all pods have been terminated, remove the associated PVCs by running `kubectl delete pvc -l owner=edb-operator`
