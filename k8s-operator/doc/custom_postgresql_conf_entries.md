## Setting custom postgresql.conf entries

When deploying postgres containers using the operator, custom postgresql.conf can be specified in the `primaryConfig` section of the deployment yaml:

```
metadata:
 name: edb-epas-12-ha

spec:
  primaryConfig:
    max_connections: "150"
```
