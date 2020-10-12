## Setting postgres superuser credentials

When deploying postgres containers using the operator, the postgres superuser credentials can be specified in [setup/kustomization.yaml](../setup/kustomization.yaml) by setting the values of `PG_USER` and `PG_PASSWORD`:

```
secretGenerator:
- name: example-pg-secret
  literals:
  - PG_USER='enterprisedb'
  - PG_PASSWORD='edb'
```
