# Deploy Postgres Containers Using CLI
Deploy PostgreSQL and EDB Postgres Advanced Server containers via the command-line interface (CLI) using the steps below. 

## Pre-deployment Steps

Complete pre-deployment steps outlined [here](k8s/Pre-Deployment)

## Deploy Container 
Use the yaml files in the examples directory for your desired deployment.

### Deploy Container As A Single Pod

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

        kubectl apply -f SinglePod/examples/epas_v11_noredwood_single.yaml

- Deploy EDB Postgres Advanced Server v11 with custom postgresql.conf settings:


        kubectl apply -f configmap.yaml

        kubectl apply -f SinglePod/examples/epas_v11_noredwood_single_custom.yaml
 
- Deploy EDB Postgres Advanced Server v11 with secret containing user credentials:


        kubectl create secret generic my-pg-secret \
        --from-literal=pgUser=myuser \
        --from-literal=pgPassword=mypassword

        kubectl apply -f SinglePod/examples/epas_v11_noredwood_single_secret.yaml
 
 
 
### Deploy Container As A StatefulSet

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

         kubectl apply -f Statefulset/examples/epas_v11_noredwood_statefulset.yaml

- Deploy EDB Postgres Advanced Server v11 with custom postgresql.conf settings:


        kubectl apply -f configmap.yaml

        kubectl apply -f Statefulset/examples/epas_v11_noredwood_statefulset_custom.yaml
 
- Deploy EDB Postgres Advanced Server v11 with secret containing user credentials:


        kubectl create secret generic my-pg-secret \
        --from-literal=pgUser=myuser \
        --from-literal=pgPassword=mypassword

        kubectl apply -f Statefulset/examples/epas_v11_noredwood_statefulset_custom.yaml

## Post-Deployment

The post-deployment steps are outlined [here](k8s/Post-Deployment)