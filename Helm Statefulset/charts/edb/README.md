# Postgres container example
These helm charts can be used by a customer, aswell as for internal deployment testing, to deploy the EDB Postgres on Kubernetes proposition Container images as a Statefulset, or single pod deployment.

## Staging
Before you can deploy with these charts, the following setup is required:
1. You need access to a Kubernetes cluster
2. You need to create the namespace to hold the deployment. Instructions can be found [here](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)
3. You need to create a secret for pulling the images from quay.io. Instructions from k8s.io can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line), where:
   * regcred should be quay-regsecret
   * <your-registry-server> is quay.io
   * <your-name> is your Docker username as used for quay.io
   * <your-pword> is your Docker password  as used for quay.io
   * <your-email> is your email address as used to retrieve the quay.io credentials
4. You need to create a service account for running the pods securely.
   Run `kubectl apply -f examples/service-account.yaml`
5. For statefulset examples, you need to create the configmap.
   Run `kubectl apply -f examples/configmap.yaml`
 6. For Openshift you need to create and use a SCC. Instructions can be found [here](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_scc.html). We attached a sample, which you can modify at your own expense:
    `kubectl apply -f examples/scc.yaml`
    `oc adm policy add-scc-to-user edb-operator-scc -z edb`

## Deploying
Below you will find some examples.
Please revert to edb/values.yaml for a total list of all options, as well as a description of how they work.

### single pod deployments
For deploying a single pod, you can run the following command:
* PostgreSQL v11: `helm install postgres11-single edb-3.0.0.tgz -f examples/pg_v11_single.yaml`
* PostgreSQL v12: `helm install postgres12-single edb-3.0.0.tgz -f examples/pg_v12_single.yaml`
* Advanced Server v10 without Oracle Compatibility: `helm install noredwood10-single edb-3.0.0.tgz -f examples/epas_v10_noredwood_single.yaml`
* Advanced Server v11 without Oracle Compatibility: `helm install noredwood11-single edb-3.0.0.tgz -f examples/epas_v11_noredwood_single.yaml`
* Advanced Server v11 with Oracle Compatibility: `helm install redwood11-single edb-3.0.0.tgz -f examples/epas_v11_redwood_single.yaml`

### Deploying as Statefulset
Note that the statefulsets without ha mode may be scaled passed 1 statefulset but will not have replication or ha...
For deploying a statefulset, you can run the following command:
* PostgreSQL v10: `helm install postgres10-statefulset edb-3.0.0.tgz -f examples/pg_v10_statefulset.yaml`
* PostgreSQL v11: `helm install postgres11-statefulset edb-3.0.0.tgz -f examples/pg_v11_statefulset.yaml`
* Advanced Server v11 without Oracle Compatibility: `helm install noredwood11-statefulset edb-3.0.0.tgz -f examples/epas_v11_noredwood_statefulset.yaml`
* Advanced Server v11 with Oracle Compatibility: `helm install redwood11-statefulset edb-3.0.0.tgz -f examples/epas_v11_redwood_statefulset.yaml`
* Advanced Server v12 with Oracle Compatibility: `helm install redwood12-statefulset edb-3.0.0.tgz -f examples/epas_v12_redwood_statefulset.yaml`

## Cleanup
### helm
The proper way to cleanup deployments is with using helm delete:
```
helm delete postgres11-single
helm delete postgres12-single
helm delete noredwood10-single
helm delete noredwood11-single
helm delete redwood11-single
helm delete postgres10-statefulset
helm delete postgres11-statefulset
helm delete noredwood11-statefulset
helm delete redwood11-statefulset
helm delete redwood12-statefulset
```
### Persistent Volume Claims
For the statefulsets you should also delete the PVC's.
```
kubectl delete pvc data-edb-epas-v11-noredwood-0 data-edb-epas-v11-redwood-0 data-edb-epas-v12-redwood-0 data-edb-pg-v10-0 data-edb-pg-v11-0 walarchive-edb-epas-v11-noredwood-0 walarchive-edb-epas-v11-redwood-0 walarchive-edb-epas-v12-redwood-0 walarchive-edb-pg-v10-0 walarchive-edb-pg-v11-0 wal-edb-epas-v11-noredwood-0 wal-edb-epas-v11-redwood-0 wal-edb-epas-v12-redwood-0 wal-edb-pg-v10-0 wal-edb-pg-v11-0
```
### Staging
If you also want to cleanup the staged objects, you could run the following:
```
kubectl delete secret quay-regsecret
kubectl delete configmap edb-db-custom-config
kubectl delete serviceaccount edb
```
