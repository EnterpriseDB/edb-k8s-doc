## Enabling Synchronous Replication

To deploy an HA cluster with Synchronous Replication between the Primary and Standbys, update the cluster specification with synchronousReplication set to true. A minimum and maximum number of synchronous Standbys can be defined as well.

Here is a sample configuration for Synchronous Replication: 

```
clusterSize: 5
   
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

Querying the Primary PostgreSQL database shows two asynchronous standbys and two synchronous standbys. This matches the spec for our deployment: clusterSize 5 and at least 1 synchronous standby and at most 2 synchronous standbys:

```
postgres=# show synchronous_standby_names;
      synchronous_standby_names      
-------------------------------------
 2 (stolon_719acd25,stolon_7b89a50c)

postgres=# select application_name,sync_state from pg_stat_replication;
 application_name | sync_state
------------------+------------
 stolon_7b89a50c  | sync
 stolon_719acd25  | sync
 stolon_59122670  | async
 stolon_aa089ee7  | async
```