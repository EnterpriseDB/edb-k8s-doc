# EDB Kubernetes Operator (edb-operator) 

## Overview

The EDB Kubernetes Operator (edb-operator) controls DBA tasks for deploying and managing EDB Postgres clusters. The edb-operator comes with the domain knowledge of a Postgres DBA for maintaining and configuring Postgres database clusters: deploy EDB Postgres with or without Streaming Replication, failover to a standby database node and keep a minimum defined number of nodes, control Postgres configuration parameters, assign metadata tags to the cluster, and configure defined compute resources automatically.

A specification for the EDB Postgres cluster is provided to the edb-operator and in turn, the operator provisions compute resources and the database server while continuously ensuring the cluster runs with the provided specification.

## Tested Platforms 

OpenShift Container Platform 4.4

## QuickStart

### Deploy the EDB Operator to your Kubernetes clusters: 

*   If using OpenShift, apply the Operator and add a Security Context Constraint (SCC) to run containers as root or specified UID in OpenShift.  :
1. From the /quickstart directory, run the following command `kubectl apply -k .`
2. Apply the scc to the operator’s user `oc adm policy add-scc-to-user edb-operator-scc -z edb-operator`
*   If you’re not using Openshift
1. From the /quickstart/operator directory, run the following command `kubectl apply -k .`


### Deploy an EDB Postgres Advanced Server (EPAS) Standalone database 

1. Deploy operator first
2. From the /quickstart directory, run the following command `kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-epas-no-ha.yaml`

### Deploy an EDB Postgres Advanced Server (EPAS) High Availability database 

1. Deploy operator first
2. From the /quickstart directory, run the following command `kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-epas-ha.yaml`

### Deploy a PostgreSQL Standalone database 

1. Deploy operator first
2. From the /quickstart directory, run the following command `kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-no-ha.yaml`

### Deploy a PostgreSQL High Availability database 

1. Deploy operator first
2. From the /quickstart directory, run the following command `kubectl apply -f examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-ha.yaml`

## Design Overview

The edb-operator is a Full Solution Operator that can be used for development and operations of stateful objects at scale. 

### Image Support 

EPAS and PostgreSQL are implemented in Red Hat Universal Base Images (UBI) 7. 

### Database Server Support  

The edb-operator supports 3 types of Postgres installations: 

*   PostgreSQL v11
*   EDB Postgres Advanced Server v11: Redwood Compatible 
*   EDB Postgres Advanced Server v11: Postgres Compatible 

### Stand Alone Cluster  

The edb-operator supports running a standalone database server by simply setting enable to false under highAvailability in the specification.  

To run a standalone database cluster (no streaming replication):, 

```
 highAvailability:
   enable: false
```

In the context of a Stand Alone Cluster, the clusterSize key determines the number of decoupled (stand alone) clusters to launch. Setting a clusterSize to 3 would launch 3 stand alone PostgreSQL nodes:

```
 clusterSize: 3
```

### High Availability (HA)  

When deploying as an HA cluster, the edb-operator automatically oversees PostgreSQL Streaming Replication health and maintenance operations. Along with deploying PostgreSQL servers with Streaming Replication, the HA setup includes a cluster-aware proxy and sentinel(s) that constantly communicate to keep the desired state. 

In the context of a HA cluster, the clusterSize key determines the number Hot Standbys: Setting a clusterSize to 5 would launch 1 Primary and 4 Hot Standbys. 

```
 clusterSize: 5
```

Looking at a deployment and along with the edb-operator, we see the cluster-aware proxy (edb-epas-11-proxy) and the watchers (edb-epas-11-sentinel):

```
$ kubectl get deploy
NAME               	READY   UP-TO-DATE   AVAILABLE   AGE
edb-epas-11-proxy  	 5/5 	  5        	    5          4d19h
edb-epas-11-sentinel 5/5 	  5        	    5          4d19h
edb-operator       	 2/2 	  2             2          4d19h
```

After deployment, we can verify the cluster in the pods: 

```
$ kubectl get pod                      	 
NAME                                	    READY   STATUS RESTARTS   AGE
edb-epas-11-0                       	    1/1 	Running   0         5d21h
edb-epas-11-1                       	    1/1 	Running   0      	5d21h
edb-epas-11-2                       	    1/1 	Running   0      	5d21h
edb-epas-11-3                       	    1/1 	Running   0      	5d21h
edb-epas-11-4                       	    1/1 	Running   0  	    5d21h
edb-epas-11-proxy-858f6bb967-bm97j  	    1/1 	Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-j6q7v  	    1/1 	Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-ntnfh  	    1/1 	Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-t6tp9  	    1/1 	Running   0      	5d21h
edb-epas-11-proxy-858f6bb967-zk29s  	    1/1 	Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-dl9bc       1/1 	Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-mwh2d       1/1 	Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-nn4fx       1/1 	Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-pdhn8       1/1 	Running   0      	5d21h
edb-epas-11-sentinel-54fff448c5-tll29       1/1 	Running   0      	5d21h
edb-operator-6b4d4494c9-hwpr5       	    1/1 	Running   0      	5d21h
edb-operator-6b4d4494c9-xwkfp       	    1/1 	Running   0      	5d21h
```


#### Proxy

All connections to the HA cluster are handled by a  proxy to ensure connections to the current Primary. The proxy provides fencing and will close databases connections to an old Primary and direct new database connections to a newly promoted Primary. 


#### Sentinel(s) 

Sentinel(s) act as watchers to keep the state of the HA cluster as defined and are responsible for monitoring the HA cluster, detecting failures, and initiating failovers and re-joins where appropriate. The state of the HA cluster is tracked and stored in a state cluster view configmap. 

Storing the state in a configmap, gives the operator the ability to change the state of the cluster by patching the changes to the configmap. Everything from reconfiguring a database to forcing a failover can is done by patching the configmap.


#### EPAS Redwood vs. Non Redwood  

EPAS is supported in compatibility with Oracle (Redwood) and without compatibility with Oracle (No Redwood). 

EPAS in Oracle Compatible Mode (Default): 


```
 noRedwoodCompat: false
```


EPAS in Postgres Compatible Mode:


```
 noRedwoodCompat: true
```


## Deployment


### System Resources  

The amount of CPU/Memory/Disk is configurable


```
 databaseMemoryLimit: "2Gi"
 databaseMemoryRequest: "1Gi"
 databaseCPULimit: "1000m"
 databaseCPU: "50m"
 databaseStorageRequest: "5Gi"
```

### Custom PostgreSQL Parameters 

The edb-operator keeps a desired state which can be managed programmatically by keeping PostgreSQL parameters in a specification. This approach keeps PostgreSQL parameters for each instance in the Streaming Replication set in sync. To modify PostgreSQL parameter values, update the primaryConfig in the specification. The following is an example from `/examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml` that modifies the PostgreSQL parameter max_connections to 150. Apply the updated specification to Kubernetes and the operator will ensure parameter changes that do not require a restart are made on each node: 

`/examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml`

```
 primaryConfig:
   max_connections: "150"
```
Apply custom PG parameters: 


```
kubectl apply -f /examples/edbpostgres.com_v1alpha1_edbpostgres_cr-11-pg-customlabels.yaml
```


The following parameters changes will be ignored:


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

## Useful Tips 

_All steps assume user has access to the Openshift GUI and kubectl in the terminal_


### Verifying your custom settings were applied 

*   Enter pod shell in the Openshift GUI
*   Login to the desired database
*   Run `SELECT * FROM pg_settings WHERE name=’<value to check>’`
*   Compare the boot_val to the reset_val, where the reset_val should be your custom setting


### Verify you’re running in Redwood (oracle compatibility) mode 

*   Enter pod shell
*   Login to the desired database
*   Run `show db_dialect`
*   For redwood mode, the output should be “redwood”, otherwise it should be “postgres”


#### Check whether a database is Primary or Standby in a High Availability deployment 

*   Enter the desired pods logs
*   If the pod is Primary, the logs will indicate every cycle that it is Primary


### Remove the operator from your cluster 

*   From the command line in the quickstart/ directory run `kubectl delete -k .`
*   After all pods have been terminated, remove the associated PVCs by running `kubectl delete pvc -l owner=edb-operator`


### Remove a database deployment from your cluster 

*   From the command line in the directory containing the deployment’s yaml is located: `kubectl delete -f <name_of_yaml_file>`
*   After all of the deployment’s pods have been terminated, remove the associated PVCs for each pod that have the same name


### Change the number of databases in a deployment 

*   From the command line in the directory containing the deployment’s yaml is located
*   Enter the yaml, adjust the clusterSize setting to the desired number
*   Run `kubectl apply -f <name_of_yaml_file>`


### Verify failover from Primary in a High Availability deployment 

*   Identify which pod in the HA deployment is currently Primary
*   Terminate the Primary pod
*   View the logs for all Secondary pods in the deployment and wait for one to begin reporting as Primary
