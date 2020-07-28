# Deploy Postgres Containers As Stateful Set Using Helm Chart
Deploy PostgreSQL and EDB Postgres Advanced Server containers as a stateful set via helm charts using the steps below. 

## 1. Install Helm
install helm by following the instructions [here](https://helm.sh/docs/intro/install/)


## 2. Verify helm version

    helm version

## 3. Create namespace in your k8s cluster
    kubectl create ns <your-namespace>
For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)

## 4. Switch to your namespace

    oc project <your-namespace>
 

## 5. Create registry secret for EDB Container Registry (quay.io)
    kubectl create secret docker-registry quay-regsecret \
     --docker-server=quay.io \
 	 --docker-username=<your-quay.io-username> \
 	 --docker-password=<your-quay.io-password> \
 	 --docker-email=<your-quay.io-email>

## 6. Create service account
    kubectl apply -f service-account.yaml

## 7. Create configmap for custom configs
    kubectl apply -f configmap.yaml

## 8. Create securty context (SCC) 
    kubectl apply -f scc.yaml
    oc adm policy add-scc-to-user edb-operator-scc -z edb

## 9. Deploy Container (as stateful set)
Use the yaml files in the examples directory for your desired deployment.

NOTE: For a complete list of available options in the yaml file, see charts/edb/values.yaml

- EDB Postgres Advanced Server v11 with redwood mode:

        helm template charts/edb -f examples/epas_v11_redwood_statefulset.yaml | kubectl apply -f -
 

## 10. Verify Deployment
    kubectl get pods

For EDB Postgres Advanced Server v11, the output from the command above if deployment is successful:

    NAME                          READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-0        1/1     Running   0          2m7s


## 11. Use Postgres

- Open a shell into the container:

        kubectl exec -it edb-epas-v11-redwood-0 -- bash

- Log into the database:

        $PGBIN/psql -d edb -U enterprisedb

- Run sample queries:

        edb=# select version();

        edb=# create table mytable1(var1 text);

        edb=# insert into mytable1 values ('hi from epas 11');

        edb=# select * from mytable1;
