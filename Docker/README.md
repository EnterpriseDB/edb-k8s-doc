# Deploy Postgres Containers Using Docker Command Line
Deploy PostgreSQL and EDB Postgres Advanced Server containers from the Docker command line using the steps below. 

## 1. Install Docker
For Windows/macOS, installing [Docker Desktop](https://www.docker.com/products/docker-desktop) is recommended


## 2. Verify Docker Version

    docker version

## 3. Login to EDB Container Registry (quay.io)
    docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>

## 4. Download Postgres Images
- Download PostgreSQL and EDB Postgres Advanced Server Postgres images from quay.io

        docker pull quay.io/edb/postgresql-11:latest
        docker pull quay.io/edb/postgres-advanced-server-11:latest


- Confirm downloaded image(s):

        docker images


## 5. Deploy Container
a. Deployment options are provided as environment variables:

| Environment Variable | Default                    | Description               |
|----------------------|----------------------------|---------------------------|
| PG_USER              | enterprisedb               | Postgres user             |
| PG_PASSWORD          | postgres(pg), edb(EPAS)    | Postgres password         |
| PG_ROOT               | /var/lib/edb          | Root directory of Postgres data, write ahead log, and write ahead log archive files. You can override the default path by creating a docker volume and setting PG_ROOT to its path |
| PGDATA               | $PG_ROOT/data          | Postgres data directory. You can override the default path by creating a docker volume and setting PGDATA to its path   |
| PGDATA_WAL           | $PG_ROOT/wal           | Postgres Write Ahead Log directory. You can override the default path by creating a docker volume and setting PGDATA_WAL to its path    |
| PGDATA_ARCHIVE       | $PG_ROOT/wal_archive   | Postgres Write Ahead Log archive directory. You can override the default path by creating a docker volume and setting PGDATA_ARCHIVE to its path |
| PG_INITDB              | true               | Indicates if the database directories will be initialized on startup. Applicable values are true or false             |
| PG_NOSTART              | false                | Indicates that another process will not start the database; override to “true” if another process will be in control of starting the database (e.g. keeper). Applicable values are true or false|
| USE_SECRET           | false                      | Use default Postgres user and password if set to false|
| USE_CONFIGMAP           | false                      | Indicates whether custom postgresql.conf settings should be used. Applicable values are true or false. To provide custom postgresql.conf settings, you have to create a docker volume and include the settings in the file named custom_postgresql.conf; the docker volume has to be mounted at the path /config during deployment |
| CHARSET              | UTF8                       | Character set             |
| NO_REDWOOD_COMPAT    | false                      | Redwood mode for EPAS     |

NOTE: For information on how to use docker volumes, refer to the documentation [here](https://docs.docker.com/storage/volumes/).

b. Deployment examples:

- PostgreSQL with all default options (v11 shown)

        docker run --name EDB-Postgres -d quay.io/edb/postgresql-11:latest /launch.sh
 
 - PostgreSQL with all user-defined username/password options (v11 shown)

        docker run --name EDB-Postgres -e USE_SECRET=true -e PG_USER=<postgres-user> -e PG_PASSWORD=<postgres-password> -d quay.io/edb/postgresql-11:latest /launch.sh

 - EDB Postgres Advanced Server with redwood mode off (v11 shown)

        docker run --name EDB-Postgres -e NO_REDWOOD_COMPAT=true -d quay.io/edb/postgres-advanced-server-11:latest /launch.sh

- PostgreSQL with persistent volume for data (v11 shown)
        
    i. create local data directory

        mkdir <local-data-directory>
    
    ii. deploy container

        docker run --name EDB-Postgres -e PGDATA=/data -v <local-data-directory>:/data -d quay.io/edb/postgresql-11:latest /launch.sh
        
c. Verify deployment:
       
       docker ps

## 6. Use Postgres

- Open a shell into the container:

        docker exec -it EDB-Postgres bash

- Log into the database (default postgres user):

        $PGBIN/psql -d postgres -U enterprisedb

- Run sample queries:

        postgres=# select version();

        postgres=# create table mytable1(var1 text);

        postgres=# insert into mytable1 values ('hi from pg 11');

        postgres=# select * from mytable1;
                                                 

