# Docker
Some customers may prefer to deploy EDB containers using Docker rather than using Helm, the Operator, or the native Kubernetes CLI. Sample commands and examples are provided for deploying PostgreSQL and EDB Postgres Advanced Server container images using Docker.
 

## Prerequisites
Complete all of the prerequisite steps before deploying the images using the Docker command line. 

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows/macOS.

2. Verify the Docker Engine version is 1.13 or later using the following command:
   ```
   docker version
   ```
3. Obtain credentials to access the  [quay.io](https://quay.io) container registry where EDB container images are published. 

4. Obtain access to [EDB's quay repositories](https://quay.io/organization/edb) by contacting EDB.

4. After receiving access, log in to the registry to pull the desired images:
   ```
   docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>
   ```
   
4. Use the Docker pull command to download PostgreSQL and EDB Postgres Advanced Server images from quay.io:

   Download PostgreSQL and EDB Postgres Advanced Server container images from quay.io
   * PostgreSQL v11
     ```
     docker pull quay.io/edb/postgresql-11:latest
     ```
   * EDB Postgres Advanced Server
     ```
     docker pull quay.io/edb/postgres-advanced-server-11:latest
     ```

5. To review a list of download images, run the following command:
   ```
   docker images
   ```

## Deploying with Docker

### Environment Variables
The following options are provided as environment variables for Docker deployments:

#### Immutable Options
| Environment Variable | Required | Default              | Description               |
|----------------------|----------|----------------------|---------------------------|
| PG_USER              | n/a      | enterprisedb         | The name of the Postgres user. PG_USER will always be  set to `enterprisedb` by the container image.  |

#### Mutable Options
| Environment Variable | Required | Default              | Description               |
|----------------------|----------|----------------------|---------------------------|
| PG_PASSWORD          | Yes      | n/a                  | The password of the Postgres user. PG_PASSWORD must be included during deployment.         |
| PG_ROOT              | No       | /var/lib/edb         | The root directory of Postgres data, write ahead log, and write ahead log archive files. The value can be overridden by creating a docker volume and setting PG_ROOT to its path. |
| PGDATA               | No       | $PG_ROOT/data        | The location of the Postgres data directory. The value can be overridden by creating a docker volume and setting PGDATA to its path.   |
| PGDATA_WAL           | No       | $PG_ROOT/wal         | The location of the Postgres Write Ahead Log directory. The value can be overridden by creating a docker volume and setting PGDATA_WAL to its path. |
| PGDATA_ARCHIVE       | No       | $PG_ROOT/wal_archive | The location oof the Postgres Write Ahead Log archive directory. The value can be overridden by creating a docker volume and setting PGDATA_ARCHIVE to its path. |
| PG_INITDB            | Yes      |                    | Indicates if the database directories will be initialized on startup. Must be set to `true`.            |
| CHARSET              | No       | UTF8                 | The default character set that will be used by the database. The value can be overridden to another valid character set.             |
| NO_REDWOOD_COMPAT    | No       | false                | Specifies that EDB Postgres Advanced Server will be installed in a mode that provides compatibility features for Oracle databases.     |


### Deployment Examples

* EDB Postgres Advanced Server with defaults and compatibility with Oracle database (redwood on) 
  ```
  docker run --detach --name edb-postgres \
  --env PG_PASSWORD=mypassword --env PG_INITDB=true \
  quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
  ```
* EDB Postgres Advanced Server with defaults and compatibility with PostgreSQL database (redwood mode off)
  ```  
  docker run --detach --name edb-postgres \
  --env PG_PASSWORD=mypassword --env PG_INITDB=true --env NO_REDWOOD_COMPAT=true \
  quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
  ```
* PostgreSQL with persistent volume for data (v11 shown)
        
    i. Create local data directory
 
        mkdir <local-data-directory>
    
    ii. Deploy a PostgreSQL container
       
        docker run --detach --name edb-postgres \
        --env PG_PASSWORD=mypassword --env PG_INITDB=true --env PGDATA=/data -v <local-data-directory>:/data \
        quay.io/edb/postgresql-11:latest bash -c '/police.sh && /launch.sh'
        
     For more information, refer to [Using Storage Volumes](https://docs.docker.com/storage/volumes/) documention from Docker.

## Verification

After deploying a container, use the following command to verify the container status:
   ```
   docker ps
   ```
   
## Using PostgreSQL

After verifying successful deployment, the PostgreSQL or EDB Postgres Advanced Server containers are ready for use.

1. Open a shell into the container:
   ```
   docker exec -it edb-postgres bash
   ```
2. Log into the database (default user):
   ```
   $PGBIN/psql -d postgres -U enterprisedb
   ```
3. Run sample queries:
   ```
   postgres=# select version();
   postgres=# create table mytable1(var1 text);
   postgres=# insert into mytable1 values ('hi from pg 11');
   postgres=# select * from mytable1;
   ```
4. (For EDB Postgres Advanced Server), check compatibility with Oracle database:   
   ```
   postgres=# show db_dialect;
   ```
   ```
   db_dialect
   -------------
   redwood
   (1 row)
   ```
   The value will be `postgres` if the database is running with compatibility with PostrgreSQL database (non-redwood).
