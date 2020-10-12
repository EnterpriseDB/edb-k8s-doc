## High Availability Deployment with edb-operator 


## Operator managed high availability

When deploying for high availability, the edb-operator automatically deploys PostgreSQL containers with Streaming Replication and oversees replication health and maintenance operations. 

The following configuration will deploy a PostgreSQL or EDB Postgres Advanced Server cluster with 3 nodes (1 primary and 2 standbys) with asynchronous replication for high availability using the Operator: 


```
spec:
  clusterSize: 3

  highAvailability: 
    enable: true
```

The deployment defaulted to asynchronous streaming replication because synchronousStandby was omitted from the specification. After creating our deployment using kubectl, 3 database nodes are up in running in their own pods


```
NAME                      READY    STATUS     RESTARTS   AGE
edb-epas-12-ha-0          1/1      Running    0          3m20s
edb-epas-12-ha-1          1/1      Running    0          2m19s
edb-epas-12-ha-2          1/1      Running    0          72s
```



## Viewing Replication Roles

### Using Stolon

### Using pgAdmin

### Finding the replicas in a database cluster
## Viewing Replication 


### Streaming Replication 

A query against the Primary (edb-epas-12-ha-0) against the dynamic pg_stat_replication view reveals two Standbys are receiving changes from the primary: 


```
edb=# select usename, client_addr, application_name, state, sync_state from pg_stat_replication;

-[ RECORD 1 ]----+----------------
usename      	| replication
client_addr  	| 10.128.4.140
application_name  | stolon_6f606125
state        	| streaming
sync_state   	| async

-[ RECORD 2 ]----+----------------
usename      	| replication
client_addr  	| 10.128.7.53
application_name  | stolon_e87b5901
state        	| streaming
sync_state   	| async
```



### Stolon Keeper

Among the processes inside each Database container is a process named edb-stolon-keeper. The Keeper is based on Stolon Keeper and manages the local PostgreSQL or EDB Postgres Advanced Server instance to ensure the cluster view computed by the Sentinel. Monitoring the Database Servers logs will also reveal references to the Keeper:


```
$ kubectl logs -f edb-epas-11-0
2020-08-27T16:23:48.093Z    INFO    cmd/keeper.go:1476    our db requested role is master
2020-08-27T16:23:48.094Z    INFO    cmd/keeper.go:1512    already master

$ kubectl logs -f edb-epas-11-1
2020-08-27T16:25:25.697Z    INFO    cmd/keeper.go:1526    our db requested role is standby    {"followedDB": "546fac43"}
2020-08-27T16:25:25.697Z    INFO    cmd/keeper.go:1545    already standby
```



### Stolon Sentinel(s)

Another critical component of the edb-operator is Sentinel(s). With the HA deployment above, 3 Sentinels(s) acting as watchers are also deployed. The Sentinel(s) are responsible for monitoring the HA cluster, detecting failures, and initiating failovers and re-joins where appropriate. The state of the HA cluster is tracked and stored in a state cluster view configmap. 

Storing the state in a configmap, gives the operator the ability to change the state of the cluster by patching the changes to the configmap. Switchover and scaling up the number of replicas can be achieved by patching the configmap.

The pod list shows an equal number of sentinels as database containers: 


```
NAME                                       READY  STATUS    RESTARTS  AGE
edb-epas-12-ha-sentinel-5488496547-5jwmj   1/1 	  Running   0         4m
edb-epas-12-ha-sentinel-5488496547-dp8tc   1/1 	  Running   0         4m
edb-epas-12-ha-sentinel-5488496547-vrhhs   1/1 	  Running   0         4m
```



### Proxy

All connections to the HA cluster are handled by a  proxy to ensure connections to the current Primary. The proxy provides fencing and will close database connections to an old Primary and direct new database connections to a newly promoted Primary. 


```
NAME                                    READY  STATUS    RESTARTS  AGE
edb-epas-12-ha-proxy-5c494bf44-2965f    1/1    Running   0         3m43s
edb-epas-12-ha-proxy-5c494bf44-rgg6h    1/1    Running   0         3m43s
edb-epas-12-ha-proxy-5c494bf44-tjhcn    1/1    Running   0         3m43s
```



## Adding Replicas 

Adding additional replicas to a PostgreSQL deployment only requires modifying the clusterSize in the CR and applying the configuration: 

```
spec:
  clusterSize: 5
```
```
$ kubectl apply -f edb-epas12-ha.yaml
```


Running `kubectl get pods` will show the newly created replicas. Here the number of replicas was scaled from 3 to 5 and two additional replicas were created: 


```
NAME                       READY  STATUS      RESTARTS  AGE
edb-epas-12-ha-0           1/1 	  Running     0         84m
edb-epas-12-ha-1           1/1 	  Running     0         83m
edb-epas-12-ha-2           1/1 	  Running     0         82m
edb-epas-12-ha-3           1/1 	  Running     0         70s
edb-epas-12-ha-4           1/1 	  Running     0         2m
```



## Synchronous Replication 

To deploy an HA cluster with Synchronous Replication between the Primary and Standbys, update the CR with synchronousReplication set to true. Minimum and maximum number of synchronous Standbys can be defined as well. 

Here is a sample configuration for Synchronous Replication: 

```

spec:
  clusterSize: 5
  
  highAvailability: 
    haClusterSettings:
      synchronousReplication: true
      minSynchronousStandbys: 1
      maxSynchronousStandbys: 2
      usePgrewind: true
      failInterval:
        duration: "10s"
      dbWaitReadyTimeout:
        duration: "30s"
```


Querying the Primary PostgreSQL database shows two asynchronous standbys and two synchronous standbys. This matches the spec for our deployment: clusterSize 5 and at least 1 synchronous standby and at most 2 synchronous standbys. 


```
postgres=# show synchronous_standby_names;
  	synchronous_standby_names 	 
-------------------------------------
 2 (stolon_719acd25,stolon_7b89a50c)
(1 row)

postgres=# select application_name,sync_state from pg_stat_replication;
 application_name | sync_state
------------------+------------
 stolon_7b89a50c  | sync
 stolon_719acd25  | sync
 stolon_59122670  | async
 stolon_aa089ee7  | async
(4 rows)
```



## Promotion

The edb-operator supports manually promoting a Standby Server as Primary. All  traffic to the database server through the proxy will resume as soon as the Standby promotion completes. 

In this example, there is 1 Primary (edb-epas-12-ha-0) and 2 Hot Standbys (edb-epas-12-ha-1 and edb-epas-12-ha-2): 


```
$ kubectl get pods
NAME                                        READY  STATUS    RESTARTS  AGE
edb-operator-7f9cc47678-wrsg7               1/1    Running   0         16h
edb-operator-7f9cc47678-xsf58               1/1    Running   0         16h
edb-epas-12-ha-0                            1/1    Running   0         6m44s
edb-epas-12-ha-1                       	    1/1    Running   0         5m41s
edb-epas-12-ha-2                       	    1/1    Running   0         4m47s
edb-epas-12-ha-proxy-f786678fd-pqlz4   	    1/1    Running   0         6m44s
edb-epas-12-ha-proxy-f786678fd-rpsrn   	    1/1    Running   0         6m44s
edb-epas-12-ha-proxy-f786678fd-w8ns2   	    1/1    Running   0         6m44s
edb-epas-12-ha-sentinel-78bdfbd5cc-6d4cs    1/1    Running   0         6m44s
edb-epas-12-ha-sentinel-78bdfbd5cc-pkb2c    1/1    Running   0         6m44s
edb-epas-12-ha-sentinel-78bdfbd5cc-ssc7z    1/1    Running   0         6m44s
```


A Failover is forced by adding the operationAction HA_FORCE_FAILOVER to the CR and then applying the configuration. 


```
 operatorAction:
   action: HA_FORCE_FAILOVER
```



## Failover

The edb-operator automatically ensures the deployment specification for clusterSize and will promote a Standby to a Primary in the event the Primary fails. To demonstrate this by manually deleting a pod will result in the edb-operator automatically promoting a Standby to a Primary, reconfiguring existing Standbys to follow the newly promoted Primary, and creating a new Standby.

There are 3 Database containers running: edb-epas-12-ha-0 is the Primary and edb-epas-12-ha-1 and edb-epas-12-ha-2 are Standbys. 


```
$ kubectl get pods

NAME                                     READY  STATUS    RESTARTS  AGE
edb-epas-12-ha-0                         1/1    Running   0         8m26s
edb-epas-12-ha-1                         1/1    Running   0         7m27s
edb-epas-12-ha-2                         1/1    Running   0         6m30s
edb-epas-12-ha-proxy-cf45d76b9-tvbjl     1/1    Running   0         8m26s
edb-epas-12-ha-proxy-cf45d76b9-vpcgf     1/1    Running   0         8m26s
edb-epas-12-ha-proxy-cf45d76b9-xxdqk     1/1    Running   0         8m26s
edb-epas-12-ha-sentinel-95b74c896-9tskc  1/1    Running   0         8m26s
edb-epas-12-ha-sentinel-95b74c896-9xvvw  1/1    Running   0         8m26s
edb-epas-12-ha-sentinel-95b74c896-jm8qs  1/1    Running   0         8m26s
edb-operator-7f9cc47678-wrsg7            1/1    Running   0         46m
edb-operator-7f9cc47678-xsf58            1/1    Running   0         46m
```


For demonstration purposes, the Primary is deleted 


```
$ kubectl delete pod edb-epas-12-ha-0

pod "edb-epas-12-ha-0" deleted
```


The Kubernetes API shows that two Database containers are running and a 3rd is being created:  


```
$ kubectl get pods
NAME                                READY  STATUS              RESTARTS   AGE
edb-epas-12-ha-0                    0/1    ContainerCreating   0          4s
edb-epas-12-ha-1                    1/1    Running             0          8m51s
edb-epas-12-ha-2                    1/1    Running             0          7m54s
```


The logs on edb-epas-11-1 shows the Keeper winning an election to becoming a the new Primary and then promoting itself: 


```
postgresql/postgresql.go:1117    We found EDB Enterprise Edition Postgres
2020-09-01T01:55:08.942Z    INFO    cmd/keeper.go:1476    our db requested role is master
2020-09-01T01:55:08.943Z    INFO    cmd/keeper.go:1505    promoting to master
2020-09-01T01:55:08.943Z    INFO    postgresql/postgresql.go:535    promoting database
waiting for server to promote.... done
server promoted
```


Logs also reveals the Operator changing its configuration for the Synchronous Standby Names of the two standbys and subsequently creating replication slots for the Standbys to receive WAL changes from: 


```
2020-09-01T01:55:09.066Z    INFO    cmd/keeper.go:1628    needed synchronous_standby_names changed    {"prevSyncStandbyNames": "", "syncStandbyNames": "2 (stolon_772d5264,stolon_e2a10ff6)"}
2020-09-01T01:55:09.066Z    INFO    cmd/keeper.go:1640    postgres parameters changed, reloading postgres instance
2020-09-01T01:55:09.067Z    INFO    cmd/keeper.go:1672    postgres hba entries not changed
2020-09-01T01:55:09.067Z    INFO    postgresql/postgresql.go:424    reloading database configuration
2020-09-01T01:55:09.067Z    INFO    postgresql/postgresql.go:1117    We found EDB Enterprise Edition Postgres
server signaled

2020-09-01T01:55:14.112Z    INFO    cmd/keeper.go:1476    our db requested role is master
2020-09-01T01:55:14.113Z    INFO    cmd/keeper.go:1512    already master

2020-09-01T01:55:19.162Z    INFO    cmd/keeper.go:980    creating replication slot    {"slot": "stolon_a1f2d726"}
2020-09-01T01:55:19.172Z    INFO    cmd/keeper.go:980    creating replication slot    {"slot": "stolon_e2a10ff6"}
```


Querying PostgreSQL on the new primary confirms the two Standbys are now receiving changes from newly promoted edb-epas-12-ha-1: 
