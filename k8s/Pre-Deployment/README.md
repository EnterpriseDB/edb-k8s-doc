# Pre-Deployment Steps For Helm Chart and CLI
Complete the steps below to make PostgreSQL and EDB Postgres Advanced Server containers ready for deployment.

## 1. Create namespace in your k8s cluster
    kubectl create ns <your-namespace>
For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)

## 2. Switch to your namespace
a. For OpenShift:

    oc project <your-namespace>
 
b. For other k8s platforms:

    kubectl config set-context --current --namespace= <your-namespace>

## 3. Create registry secret for EDB Container Registry (quay.io)
    kubectl create secret docker-registry quay-regsecret \
     --docker-server=quay.io \
 	 --docker-username=<your-quay.io-username> \
 	 --docker-password=<your-quay.io-password> \
 	 --docker-email=<your-quay.io-email>

For more details see the official k8s doc [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line)

## 4. Create service account
    kubectl apply -f service-account.yaml

If running on OpenShift, also create securty context (SCC):

    kubectl apply -f scc.yaml
    oc adm policy add-scc-to-user edb-operator-scc -z edb
