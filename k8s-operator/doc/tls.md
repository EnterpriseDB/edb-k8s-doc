
## Database Communication over SSL/TLS

SSL/TLS access to Postgres can be managed by the deployment configuration by creating a K8s secret with a private certificate and setting `tlsEnabled` to `true` under the `highAvailablity` spec.  

## TLS Description 

|       Parameter       |                                               Note                                              |
|:---------------------:|:-----------------------------------------------------------------------------------------------:|
| tlsEnabled            | Optional:  Set to true to enable SSL connections from the database client to Postgres database. |
| certificateSecretName | This is the certificate secret to use. It will be mounted in the Pods                           |

## Sample TLS CR

```
 highAvailability:
   enable: true
   tls:
     tlsEnabled: true
     certificateSecretName: "edb-tls-secret"
   image: "quay.io/edb/stolon:latest"
```

## Additional Notes 

See the [PostgreSQL SSL/TLS setup](https://github.com/sorintlab/stolon/blob/master/doc/ssl.md) notes from the Stolon project for additional details on enabling client side full verification.
