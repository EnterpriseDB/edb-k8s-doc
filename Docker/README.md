# Deploy Postgres Containers Using Docker Command Line
Deploy community Postgres and EPAS containers from the docker command line using the steps below.

## 1. Install docker
a. windows/mac: install [docker desktop](https://www.docker.com/products/docker-desktop)

b. Linux(CentOS/RHEL):

    sudo yum install -y docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker


## 2. Verify docker version

    docker version

## 3. Login to EDB Container Registry (quay.io)
    docker login quay.io -u <your-quay.io-username> -p <your-quay.io-password>

## 4. Download Postgres Images
- Download community and EPAS (v11) Postgres images from quay.io

        docker pull quay.io/enterprisedb/postgresql11:latest
        docker pull quay.io/enterprisedb/postgres11-advanced-server:latest


- Confirm downloaded image(s):

        docker images


## 5. Deploy Container
a. Deployment options are provided as environment variables:

| Environment Variable | Default                    | Description               |
|----------------------|----------------------------|---------------------------|
| PG_USER              | enterprisedb               | Postgres user             |
| PG_PASSWORD          | postgres(pg), edb(EPAS)    | Postgres password         |
| USE_SECRET           | false                      | Use default Postgres user and password if set to false|
| PGDATA               | /var/lib/edb/data          | Postgres data directory   |
| PGDATA_WAL           | /var/lib/edb/wal           | Postgres wal directory    |
| PGDATA_ARCHIVE       | /var/lib/edb/wal_archive   | Postgres archive wal dir  |
| CHARSET              | UTF8                       | Character set             |
| NO_REDWOOD_COMPAT    | false                      | Redwood mode for EPAS     |

b. Deployment examples:

- with all default options (community postgres v11)

        docker run --name EDB-Postgres -d quay.io/enterprisedb/postgresql11:latest /launch.sh
 
 - with all user-defined username/password options (community postgres v11)

        docker run --name EDB-Postgres -e USE_SECRET=true -e PG_USER=<postgres-user> -e PG_PASSWORD=<postgres-password> -d quay.io/enterprisedb/postgresql11:latest /launch.sh

 - with redwood mode off (EPAS v11)

        docker run --name EDB-Postgres -e NO_REDWOOD_COMPAT=true -d quay.io/enterprisedb/postgres11-advanced-server:latest /launch.sh

- with persistent volume for data (community postgres v11)
        
    i. create local data directory

        mkdir <local-data-directory>
    
    ii. deploy container

        docker run --name EDB-Postgres -e PGDATA=/data -v <local-data-directory>:/data -d quay.io/enterprisedb/postgresql11:latest /launch.sh
        
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
                                                 

