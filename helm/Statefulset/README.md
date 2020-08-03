# Deploy Postgres Containers As Stateful Set Using Helm Chart
Deploy PostgreSQL and EDB Postgres Advanced Server containers as a stateful set via helm charts using the steps below. 

## 1. Install Helm
install helm by following the instructions [here](https://helm.sh/docs/intro/install/)


## 2. Verify helm version

    helm version
NOTE: The helm version should 3.x

## 3. Create namespace in your k8s cluster
    kubectl create ns <your-namespace>

For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)

## 4. Switch to your namespace
a. For OpenShift:

    oc project <your-namespace>
 
b. For other k8s platforms:

    kubectl config set-context --current --namespace= <your-namespace>
 

## 5. Create registry secret for EDB Container Registry (quay.io)
    kubectl create secret docker-registry quay-regsecret \
     --docker-server=quay.io \
 	 --docker-username=<your-quay.io-username> \
 	 --docker-password=<your-quay.io-password> \
 	 --docker-email=<your-quay.io-email>

For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)

## 6. Create service account
    kubectl apply -f service-account.yaml


If running on OpenShift, also create securty context (SCC):

    kubectl apply -f scc.yaml
    oc adm policy add-scc-to-user edb-operator-scc -z edb

## 7. Create configmap for custom configs
    kubectl apply -f configmap.yaml

## 8. Deploy Container (as stateful set)
Use the yaml files in the examples directory for your desired deployment.

NOTE: For a complete list of available options in the yaml file, see charts/edb/values.yaml

- EDB Postgres Advanced Server v11 with redwood mode:

        helm install epas-v11-redwood-statefulset charts/edb -f examples/epas_v11_redwood_statefulset.yaml
 

## 9. Verify Deployment
    kubectl get pods

For EDB Postgres Advanced Server v11, the output from the command above if deployment is successful:

    NAME                          READY   STATUS    RESTARTS   AGE
    edb-epas-v11-redwood-0        1/1     Running   0          2m7s


## 10. Use Postgres

a. Access via the k8s CLI tool (kubectl):

- Open a shell into the container:

        kubectl exec -it edb-epas-v11-redwood-0 -- bash

- Log into the database:

        $PGBIN/psql -d edb -U enterprisedb

- Run sample queries:

        edb=# select version();

        edb=# create table mytable1(var1 text);

        edb=# insert into mytable1 values ('hi from epas 11');

        edb=# select * from mytable1;

b. Remote access from a client application:

- Forward a local port to the database port in the container:

        kubectl port-forward edb-epas-v11-redwood-single <local-port>:5444

- Access the postgres database from a client application, e.g. pgadmin, using the localhost address (127.0.0.1 or ::1) and \<local-port\> as referenced in the previous step
