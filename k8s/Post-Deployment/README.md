# Post-Deployment Steps
Use the steps below to validate the deployment of PostgreSQL and EDB Postgres Advanced Server containers.


## Verify Deployment
    kubectl get pods

If deployment is successful, the output of the command above for EDB Postgres Advanced Server v11 is shown below:

Single Pod:

    NAME                          READY   STATUS    RESTARTS   AGE
    edb-epas-v11-noredwood-single   1/1     Running   0          2m7s

StatefulSet:

    NAME                          READY   STATUS    RESTARTS   AGE
    edb-epas-v11-noredwood-0        1/1     Running   0          2m7s

## Use Postgres

a. Access via the k8s CLI tool (kubectl):


- Open a shell into the container:

Single Pod:

        kubectl exec -it edb-epas-v11-noredwood-single -- bash

StatefulSet:

        kubectl exec -it edb-epas-v11-noredwood-0 -- bash

- Log into the database:

        $PGBIN/psql -d postgres -U enterprisedb

- Run sample queries:

        edb=# select version();

        edb=# create table mytable1(var1 text);

        edb=# insert into mytable1 values ('hi from epas 11');

        edb=# select * from mytable1;

b. Remote access from a client application:

- Forward a local port to the database port in the container:

        kubectl port-forward edb-epas-v11-noredwood-single <local-port>:5444

- Access the postgres database from a client application, e.g. pgadmin, using the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step


## Cleanup
To cleanup the deployments, use the instructions [here](../Cleanup/README.md)
