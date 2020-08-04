# Deploy Postgres Containers Using Helm Chart
Deploy PostgreSQL and EDB Postgres Advanced Server containers via helm charts using the steps below. 

## Pre-deployment Steps

Complete pre-deployment steps outlined in k8s/Pre-Deployment

## Install Helm
install helm by following the instructions [here](https://helm.sh/docs/intro/install/)

## Verify helm version

    helm version
NOTE: The helm version should 3.x

## Deploy Container 
Use the yaml files in the examples directory for your desired deployment.

### Deploy Container As A Single POd

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

        helm install epas-v11-noredwood-single SinglePod/charts/postgresql -f SinglePod/examples/values-epas_v11_noredwood_single.yaml
 
- Deploy Community Postgres v11:

        helm install pg-v11-single SinglePod/charts/postgresql -f SinglePod/examples/values-pg_v11_single.yaml

### Deploy Container As A StatefulSet

- Deploy EDB Postgres Advanced Server v11 with no redwood mode:

        helm install epas-v11-noredwood-statefulset Statefulset/charts/postgresql -f Statefulset/examples/values-epas_v11_noredwood_statefulset.yaml
 


- Deploy Community Postgres v11:

        helm install pg-v11-statefulset Statefulset/charts/postgresql -f Statefulset/examples/values-pg_v11_statefulset.yaml

NOTE: For a complete list of available options in the yaml file, see charts/edb/values.yaml


## Post-Deployment

The post-deployment steps are outlined in k8s/Post-Deployment