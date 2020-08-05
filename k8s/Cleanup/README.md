# Cleanup Steps For Helm Chart and CLI
Complete the steps below to delete k8s objects and helm chart before redeployment.

## Delete helm chart

If deploying via helm, delete the helm chart for your deployment:

    helm delete epas-v11-noredwood-single
    helm delete pg-v11-single
    helm delete epas-v11-noredwood-statefulset
    helm delete pg-v11-statefulset

## Delete k8s objects

If deploying via the CLI, delete the following k8s objects:

    kubectl delete secret quay-regsecret
    kubectl delete configmap edb-db-custom-config
    kubectl delete serviceaccount edb

## Delete Persistent Volume Claims (PVC)

If deploying containers as Statefulsets, also delete the persistent volume claims:

- EDB Postgres Advanced Server v11 with no redwood mode:

        kubectl delete pvc data-edb-epas-v11-noredwood-0 \
        walarchive-edb-epas-v11-noredwood-0 \ 
        wal-edb-epas-v11-noredwood-0

- Community Postgres v11:   

        kubectl delete pvc data-edb-pg-v11-0 \
        walarchive-edb-pg-v11-0 \
        wal-edb-pg-v11-0

