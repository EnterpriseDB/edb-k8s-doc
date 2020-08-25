# Deploy Postgres Containers Using Docker Command Line
Deploy PostgreSQL and EDB Postgres Advanced Server containers from the Docker command line using the steps below. 

## Prerequisites
Before deploying the images using Docker, please ensure the prerequisite requirements have been met. 

1. Install Docker
For Windows/macOS, installing [Docker Desktop](https://www.docker.com/products/docker-desktop) is recommended

2. Verify Docker Version
   Confirm that running Docker Engine version 1.13 or above.
   ```
   docker version
   ```

3. Login to EDB Container Registry (quay.io)

   EDB container images are available in quay.io. The repo is currently private and requires EDB permission to access. After
receiving access, log in to pull the desired images.
   ```
   docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>
   ```
   
4. Download Postgres Images

   Download PostgreSQL and EDB Postgres Advanced Server Postgres images from quay.io
   ```
   docker pull quay.io/edb/postgresql-11:latest
   docker pull quay.io/edb/postgres-advanced-server-11:latest
   ```

5. Confirm downloaded image(s):
   ```
   docker images
   ```

## Deploying

### Environment Variables
The following options are provided as environment variables for Docker deployments:

| Environment Variable | Default              | Description               |
|----------------------|----------------------|---------------------------|
| PG_USER              | enterprisedb         | Postgres user             |
| PG_PASSWORD          |                      | Postgres password. User must include value when deploying         |
| PG_ROOT              | /var/lib/edb         | Root directory of Postgres data, write ahead log, and write ahead log archive files. Override the default path by creating a docker volume and setting PG_ROOT to its path |
| PGDATA               | $PG_ROOT/data        | Postgres data directory. Override the default path by creating a docker volume and setting PGDATA to its path   |
| PGDATA_WAL           | $PG_ROOT/wal         | Postgres Write Ahead Log directory. Override the default path by creating a docker volume and setting PGDATA_WAL to its path    |
| PGDATA_ARCHIVE       | $PG_ROOT/wal_archive | Postgres Write Ahead Log archive directory. Override the default path by creating a docker volume and setting PGDATA_ARCHIVE to its path |
| PG_INITDB            |                      | Indicates if the database directories will be initialized on startup. Should be set to `true`             |
| CHARSET              | UTF8                 | Character set. Override to another valid character set if desired             |
| NO_REDWOOD_COMPAT    | false                | Redwood mode for EPAS     |

**NOTE**: For information on how to use docker volumes, refer to the documentation [here](https://docs.docker.com/storage/volumes/).

### Deployment Examples

- EDB Postgres Advanced Server with all default options (v11 shown)
  ```
  docker run --detach --name edb-postgres --env PG_INITDB=true \
  quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
  ```
 - EDB Postgres Advanced Server with all user-defined username/password options (v11 shown)
   ```
   docker run --detach --name edb-postgres --env PG_INITDB=true \
   --env PG_USER=myuser --env PG_PASSWORD=mypassword --env USE_SECRET=true \
   quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
   ```
 - EDB Postgres Advanced Server with redwood mode off (v11 shown)
   ```  
   docker run --detach --name edb-postgres --env PG_INITDB=true --env NO_REDWOOD_COMPAT=true \
   quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
   ```
- PostgreSQL with persistent volume for data (v11 shown)
        
    i. create local data directory
 
        mkdir <local-data-directory>
    
    ii. deploy container

        docker run --detach --name edb-postgres --env PG_INITDB=true \
        --env PGDATA=/data -v <local-data-directory>:/data \
        quay.io/edb/postgresql-11:latest bash -c '/police.sh && /launch.sh'
        
## Verification
   ```
   docker ps
   ```
   
## Using Postgres

1. Open a shell into the container:
   ```
   docker exec -it EDB-Postgres bash
   ```
2. Log into the database (default postgres user):
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
4. Check Redwood Mode (EPAS):      
   ```
   postgres=# show edb_redwood_date;
   ```
   ```
   edb_redwood_date
   ------------------
   off
   (1 row)
   ```
