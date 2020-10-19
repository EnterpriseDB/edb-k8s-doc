# Docker
Some customers may prefer to deploy EDB containers using Docker rather than using Helm, the Operator, or the native Kubernetes CLI. Sample commands and examples are provided for deploying PostgreSQL and EDB Postgres Advanced Server container images using Docker.
 

## Prerequisites
Complete all of the prerequisite steps before deploying the images using the Docker command line. 

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows/macOS.

1. (For Windows) perform these additional steps:

   * Install [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/)
   * Launch WSL and login to your Linux (e.g., Ubuntu) instance
   * Add your user account to the `docker` group using the command:
      ```
      sudo gpasswd -a $USER docker
      ```
      NOTE: You have to logout and log back in for the command to take effect
   

1. Verify the Docker Engine (Community) version is 19.03 or later using the following command:
   ```
   docker version
   ```

1. Confirm [access](github.com/EnterpriseDB/edb-k8s-doc/README.md) to quay.io and EDB's repositories by logging in to the quay.io registry to view the desired images: 
   ```
   docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>
   ```
   
1. Use the Docker pull command to download PostgreSQL and EDB Postgres Advanced Server images from quay.io:

   * PostgreSQL v12
     ```
     docker pull quay.io/edb/postgresql-12:latest
     ```
   * EDB Postgres Advanced Server v12
     ```
     docker pull quay.io/edb/postgres-advanced-server-12:latest
     ```

1. To review a list of downloaded images, run the following command:
   ```
   docker images
   ```

## Environment Variables
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
| PG_INITDB            | Yes      |                    | Indicates if the database directories should be initialized on startup. Must be set to `true`, unless deploying a PostgreSQL container with persistent storage already initialized.      |
| CHARSET              | No       | UTF8                 | The default character set that will be used by the database. The value can be overridden to another valid character set.             |
| NO_REDWOOD_COMPAT    | No       | false                | Specifies if EDB Postgres Advanced Server will be installed in a mode that does not provide compatibility features for Oracle databases.  Compatibility with Oracle will be provided by default.  Must be overridden to `true` if compatability with Oracle is not needed.   |

## Deploy using Docker Command Line

* EDB Postgres Advanced Server with defaults and compatibility with Oracle database (redwood) 
  ```
  docker run --detach --name edb-postgres \
  --env PG_PASSWORD=mypassword --env PG_INITDB=true \
  quay.io/edb/postgres-advanced-server-12:latest bash -c '/police.sh && /launch.sh'
  ```

* EDB Postgres Advanced Server with defaults and compatibility with PostgreSQL database (no redwood)
  ```
  docker run --detach --name edb-postgres \
  --env PG_PASSWORD=mypassword --env PG_INITDB=true --env NO_REDWOOD_COMPAT=true \
  quay.io/edb/postgres-advanced-server-12:latest bash -c '/police.sh && /launch.sh'
  ```

* EDB Postgres Advanced Server with defaults and persistent data

  * Delete storage volume `pgdata` in case it already exists

    ```
    docker volume rm pgdata
    ```

  * Create storage volume `pgdata`

    ```
    mkdir data
    docker volume create --driver local --opt type=none --opt device="$(pwd)"/data --opt o=bind pgdata
    ```
   For more information on using Storage Volumes, refer to the [Docker](https://docs.docker.com/storage/volumes/) documentation.

  * Deploy EDB Postgres Advanced Server container
      ```
      docker run --detach --name edb-postgres \
      --env PG_PASSWORD=mypassword --env PG_INITDB=true --env PGDATA=/data -v pgdata:/data \
      quay.io/edb/postgres-advanced-server-12:latest bash -c '/police.sh && /launch.sh'
      ```


## Deploy using Docker Compose

* EDB Postgres Advanced Server with defaults and compatibility with Oracle database (redwood)  
  ```
  docker-compose -f examples/epas_v12.yaml up --detach
  ```

* EDB Postgres Advanced Server with defaults and compatibility with PostgreSQL database (no redwood)
    ```
    docker-compose -f examples/epas_v12_noredwood.yaml up --detach
    ```

* EDB Postgres Advanced Server with defaults and persistent data

  * Delete storage volume `pgdata` in case it already exists

    ```
    docker volume rm pgdata
    ```

  * Create storage volume `pgdata`
  
    ```
    mkdir data
    docker volume create --driver local --opt type=none --opt device="$(pwd)"/data --opt o=bind pgdata
    ```
    
   * Deploy EDB Postgres Advanced Server container   
     ```
     docker-compose -f examples/epas_v12_pgdata.yaml up --detach
     ```


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
1. Log into the database (default user):
   ```
   $PGBIN/psql -d postgres -U enterprisedb
   ```
1. Run sample queries:
   ```
   postgres=# select version();
   postgres=# create table mytable1(var1 text);
   postgres=# insert into mytable1 values ('hi from pg 12');
   postgres=# select * from mytable1;
   ```
1. (For EDB Postgres Advanced Server), check compatibility with Oracle database:   
   ```
   postgres=# show db_dialect;
   ```
   ```
   db_dialect
   -------------
   redwood
   (1 row)
   ```
   The value will be `postgres` if the database is running with compatibility with PostrgreSQL database (no redwood).

1. If container is deployed with data persistence, you can verify data is preserved using the following steps:
   
   *  Delete the container
      ```
      docker rm edb-postgres --force
      ```
   * Redeploy the container with `PG_INITDB` set to `false`:
      ```
      docker run --detach --name edb-postgres \
      --env PG_PASSWORD=mypassword --env PG_INITDB=false --env PGDATA=/data -v pgdata:/data \
      quay.io/edb/postgres-advanced-server-12:latest bash -c '/police.sh && /launch.sh'
      ```
   * Open a shell into the container, log into the database as previously shown and oonfirm data previously created by running the query:
      ```
      postgres=# select * from mytable1;
      ```