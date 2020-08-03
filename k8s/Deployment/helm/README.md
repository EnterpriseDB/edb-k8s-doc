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

- Deploy EDB Postgres Advanced Server v11 with redwood mode:

        helm install epas-v11-redwood-single SinglePod/charts/edb -f SinglePod/examples/epas_v11_redwood_single.yaml
 

### Deploy Container As A StatefulSet

- Create configmap for custom configs

        kubectl apply -f Statefulset/configmap.yaml

- Deploy EDB Postgres Advanced Server v11 with redwood mode:

        helm install epas-v11-redwood-statefulset Statefulset/charts/edb -f Statefulset/examples/epas_v11_redwood_statefulset.yaml
 

NOTE: For a complete list of available options in the yaml file, see charts/edb/values.yaml


## Post-Deployment

The post-deployment steps are outlined in k8s/Post-Deployment