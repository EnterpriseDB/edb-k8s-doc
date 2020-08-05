# Deploy Postgres Containers Using CLI
Deploy PostgreSQL and EDB Postgres Advanced Server containers via the command-line interface (CLI) using the steps below. 

## Pre-deployment Steps

Complete pre-deployment steps outlined in k8s/Pre-Deployment

## Deploy Container 
Use the yaml files in the examples directory for your desired deployment.

### Deploy Container As A Single Pod

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

        kubectl apply -f SinglePod/examples/epas_v11_noredwood_single.yaml
 
 
### Deploy Container As A StatefulSet

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

         kubectl apply -f Statefulset/examples/epas_v11_noredwood_statefulset.yaml
 

## Post-Deployment

The post-deployment steps are outlined in k8s/Post-Deployment