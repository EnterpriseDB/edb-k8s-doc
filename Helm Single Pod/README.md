# Deploy Postgres Containers Using Helm Chart
Deploy PostgreSQL and EDB Postgres Advanced Server containers as a single pod via helm charts using the steps below. 

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

## 7. Create securty context (SCC) 
    kubectl apply -f scc.yaml
    oc adm policy add-scc-to-user edb-operator-scc -z edb

## 8. Deploy Container 
Use the yaml files in the examples directory for your desired deployment.
NOTE: For a complete list of available options in the yaml file, see charts/edb/values.yaml

- EDB Postgres Advanced Server v11 with redwood mode:

        helm template charts/edb -f examples/epas_v11_redwood_single.yaml | kubectl apply -f -
 

## 9. Verify Deployment
    kubectl get pods

For EDB Postgres Advanced Server v11, the output from the command above if deployment is successful:

    NAME                          READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-single   1/1     Running   0          2m7s


## 10. Use Postgres

- Open a shell into the container:

        kubectl exec -it edb-epas-v11-redwood-single -- bash

- Log into the database:

        $PGBIN/psql -d edb -U enterprisedb

- Run sample queries:

        edb=# select version();

        edb=# create table mytable1(var1 text);

        edb=# insert into mytable1 values ('hi from epas 11');

        edb=# select * from mytable1;
