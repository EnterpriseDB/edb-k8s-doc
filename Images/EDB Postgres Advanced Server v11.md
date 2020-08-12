# What is PostgreSQL?

> [PostgreSQL](http://www.postgresql.org) also known as Postgres, is a free and open-source relational database management system (RDBMS)[[source]](https://en.wikipedia.org/wiki/PostgreSQL).

> EDB Postgres Advanced Server (EPAS) is an enhanced version of open source PostgreSQL. EDB Postgres Advanced Server is continuously synchronized with PostgreSQL and adds functionality such as enterprise security, performance diagnostics, Oracle® database compatibility, and productivity features for developers and DBAs [source](https://info.enterprisedb.com/rs/069-ALB-339/images/edb-postgres-advanced-server-ds.pdf?_ga=2.121784267.132786095.1597065397-115782412.1590602128).

# TL;DR

```console
$ docker run --name edb-postgres -p 5444:5444 quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
```

## Docker Compose

```console
$ curl -sSL https://raw.githubusercontent.com/EnterpriseDB/edb-k8s-se/master/Docker/docker-compose-epas.yaml > docker-compose.yaml
$ docker-compose up -d
```

# Why Use EDB Container Images?

* EDB closely tracks upstream source changes and promptly publishes new versions of this image using our automated systems.
* With EDB Container images, the latest bug fixes and features are available as soon as possible.
* All our images are based on the [ubi7](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) container image.
* EDB Container images with the latest distribution packages are released, whenever: 
    * Common Vulnerabilities and Exposures are resolved in the base image, and/or 
    * New versions of the Postgres binaries are available.



> The [Common Vulnerabilities and Exposures scan reports](https://quay.io/repository/edb/postgres-advanced-server-11?tab=tags) contains a security report with all open CVEs.

To get the list of actionable security issues, find the ``latest`` tag and click the ``Vulnerability Report`` link under the corresponding ``Security scan`` field. On the next page, select the ``Only show fixable`` filter.



# Deploying Postgres in Kubernetes

EDB Containers can be deployed using Helm Charts. For more information, see [EDB Charts GitHub Repository](https://github.com/EnterpriseDB/edb-k8s-se/tree/master/k8s/Deployment/helm).
EDB Containers can be used with [Kubeapps](https://kubeapps.com/) for deployment and management of Helm Charts in clusters.


# Supported Tags

Learn more about the EDB container image tagging policy and the available images and image repositories in our [Tagging policy document](https://github.com/EnterpriseDB/edb-k8s-se/tree/master/k8s/Images/tagging_policy.md).

`ubi7-amd64, latest`

Subscribe to project updates by watching the [EDB GitHub repository](https://github.com/EnterpriseDB/edb-k8s-se/tree/master).


# Deploying an EDB Postgres Docker Image

Before deploying the EDB Postgres Docker Image, you must obtain [quay.io](http://quay.io) credentials to pull the prebuilt image from the [repository](https://quay.io/repository/edb/postgres-advanced-server-11:latest).

```console
$ docker pull quay.io/edb/postgres-advanced-server-11:latest
```

To use a specific version, you can pull a versioned tag. You can view the [list of available versions](https://quay.io/repository/edb/postgres-advanced-server-11) in the Quay container registry.


# Ensuring that Data Persists Between Containers

When you remove a container, all the data and configurations are deleted; when you spin up a new container, the database will be reinitialized, creating a database server in a pristine state.
To make data persist between containers, you must provide a mounted volume.

You can use the one of the following methods to persist data:

- Using environment variables
- Using a docker-compose.yaml file

## Using Environment Variables

You can use environment variables with a docker run command or a docker .yaml file to attach extra volumes. Use the following using environment variables with a docker run command:

**Note** If you omit any of the environment variables (PGDATA, PGDATA_WAL (write ahead log), or PGDATA_ARCHIVE (wal archives)), the corresponding volume will not persist.

```console
$ docker run \
    ...
    -e PGDATA=/path/to/pgdata \
    -v /path/to/pgdata:/pgdata-mountpoint \
    -e PGDATA_WAL=/path/to/pg_wal \
    -v /path/to/pg_wal:/pg_wal-mountpoint \
    -e PGDATA_ARCHIVE=/path/to/wal_archive \
    -v /path/to/wal_archive:/wal_archive-mountpoint
```

**Note**: See the section on Environment variables for descriptions and other available environment variables.

## Using a docker-compose.yaml file

For persistence, you can also modify the following parameters in the [`docker-compose.yaml`](https://github.com/EnterpriseDB/edb-k8s-se/blob/master/Docker/docker-compose-epas.yaml) file:

```yaml
services:
  edb-postgres
  ...
    volumes:
      - /path/to/pgdata:/var/lib/edb/data
      - /path/to/pgdata:/var/lib/edb/pg_wal

  ...
```

# Connecting to Other Containers

Using [Docker container networking](https://docs.docker.com/engine/userguide/networking/), a Postgres server running inside a container can easily be accessed by your application containers.

Containers attached to the same network can communicate with each other using the container name as the hostname.

## Using the Command Line

Use the following steps to create a Postgres client instance that connects to the server instance, and runs on the same docker network as the client:

1. Create a network.

    ```console
    $ docker network create app-tier --driver bridge
    ```

2. Launch the Postgres server instance.

   Use the `--network app-tier` argument to the `docker run` command to attach the Postgres container to the `app-tier` network.

    ```console
    $ docker run -d -p 5444:5444 --name edb-postgres \
        --network app-tier \
        quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
    ```

3. Launch your Postgres client instance.

   A new container instance is created to launch the Postgres client and connect to the server created in the previous step:

    ```console
    $ docker run -it --rm \
        --network app-tier \
        <postgres-client-container> psql -h edb-postgres -d postgres -U enterprisedb
    ```

## Using Docker Compose

By default, Docker Compose automatically creates a new network and attaches all deployed services to that network. However, we will explicitly define a new bridge network named ``app-tier``.

In this example, we assume that you want to connect to the Postgres server from your custom application image, identified in the following snippet by the service name ``myapp``.


```yaml
version: '2'

networks:
  app-tier:
    driver: bridge

services:
  edb-postgres
    image: 'quay.io/edb/postgres-advanced-server-11:latest'
    networks:
      - app-tier
  myapp:
    image: 'YOUR_APPLICATION_IMAGE'
    networks:
      - app-tier
```

To use the example:
>
> 1. Update the ``YOUR_APPLICATION_IMAGE_ placeholder`` mentioned in the earlier snippet with your application image.

> 2. In your application container, use the hostname postgres to connect to the Postgres server.

Run the following command, to launch the containers:

```console
$ docker-compose up -d
```

# Configuration

## Creating the Postgres Superuser Credentials

By default, on a PostgreSQL database cluster, the superuser is named postgres; on an Advanced Server instance, the superuser is named enterprisedb. To use non-default Postgres superuser credentials (user and password), provide corresponding values with environment variables:

```console
$ docker run -it --rm \
    -e USE_SECRET=true \
    -e PG_USER=mypguser \
    -e PG_PASSWORD=mypgpassword \
    -d quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
```

or modify the [`docker-compose.yaml`](https://github.com/EnterpriseDB/edb-k8s-se/blob/master/Docker/docker-compose-epas.yaml) file present in the repository:

```yaml
services:
  edb-postgres
  ...
    environment:
      - USE_SECRET=true
      - PG_PASSWORD=mypgpassword
      - PG_USER=mypguser
  ...
```


## Providing a Custom Configuration

To provide custom postgresql.conf settings for postgres, mount a volume in the container at ``/config/`` with the file named ``custom_postgresql.conf`` that contains the custom postgresql.conf settings.


```console
/path/to/custom-postgresql-conf/
└── custom_postgresql.conf

0 directories, 1 file
```

To configure the file, complete the following steps:


1. Create or edit the configuration on your host using any editor.

    ```console
    vi /path/to/custom-postgresql-conf/custom_postgresql.conf
    ```

2. Run the Postgres image, mounting a directory from your host.

    ```console
    $ docker run -p 5444:5444 --name edb-postgres \
        -e USE_CONFIGMAP=true \
        -v /path/to/custom-postgresql-conf:/config \
        -d quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
    ```

    or use Docker Compose:

    ```yaml
    version: '2'

    services:
      edb-postgres
        image: 'quay.io/edb/postgres-advanced-server-11:latest'
        ports:
          - '5444:5444'
        volumes:
          - /path/to/custom-postgresql-conf:/config
    ```


## Specifying initdb Arguments

The following environment variables can be used to specify extra initdb arguments.

 - `CHARSET`: Specifies character set. Defaults to UTF8.
 - `NO_REDWOOD_COMPAT`: Specifies no redwood compatibility mode. Defaults to false.

```console
$ docker run -p 5444:5444 --name edb-postgres \
  -e CHARSET="UTF8" \
  -e NO_REDWOOD_COMPAT="true" \
  quay.io/edb/postgres-advanced-server-11:latest bash -c '/police.sh && /launch.sh'
```

or modify the [`docker-compose.yaml`](https://github.com/EnterpriseDB/edb-k8s-se/blob/aziz-k8s-readme-updates/Docker/docker-compose-epas.yaml) file present in the repository:

```yaml
services:
  edb-postgres
  ...
    environment:
      - CHARSET="UTF8"
      - NO_REDWOOD_COMPAT="true"
  ...
```

## Environment Variables

The EDB Postgres Advanced Server container images allows the following environment variables:

| Environment Variable | Default                    | Description               |
|----------------------|----------------------------|---------------------------|
| PG_USER              | enterprisedb               | Postgres user             |
| PG_PASSWORD          | postgres(pg), edb(EPAS)    | Postgres password         |
| PG_ROOT               | /var/lib/edb          | Root directory of Postgres data, write ahead log, and write ahead log archive files. You can override the default path by creating a docker volume and setting PG_ROOT to its path |
| PGDATA               | /var/lib/edb/data          | Postgres data directory. You can override the default path by creating a docker volume and setting PGDATA to its path   |
| PGDATA_WAL           | /var/lib/edb/wal           | Postgres Write Ahead Log directory. You can override the default path by creating a docker volume and setting PGDATA_WAL to its path    |
| PGDATA_ARCHIVE       | /var/lib/edb/wal_archive   | Postgres Write Ahead Log archive directory. You can override the default path by creating a docker volume and setting PGDATA_ARCHIVE to its path |
| PG_INITDB              | true               | Indicates if the database directories will be initialized on startup. Applicable values are true or false             |
| PG_NOSTART              | false                | Indicates that another process will not start the database; override to “true” if another process will be in control of starting the database (e.g. keeper). Applicable values are true or false|
| USE_SECRET           | false                      | Use default Postgres user and password if set to false|
| USE_CONFIGMAP           | false                      | Indicates whether custom postgresql.conf settings should be used. Applicable values are true or false. To provide custom postgresql.conf settings, you have to create a docker volume and include the settings in the file named custom_postgresql.conf; the docker volume has to be mounted at the path /config during deployment |
| CHARSET              | UTF8                       | Character set             |
| NO_REDWOOD_COMPAT    | false                      | Redwood mode for EPAS     |


# Logging

The Postgres Container image directs container logs to stdout. Use the following commands to view the logs:

```console
$ docker logs edb-postgres
```

or use Docker Compose:

```console
$ docker-compose logs edb-postgres
```

You can configure the containers [logging driver](https://docs.docker.com/engine/admin/logging/overview/) using the `--log-driver` option if you wish to consume the container logs differently. In the default configuration, Docker uses the `json-file` driver.

# Issues

If you encounter a problem while running this container, you can file an [issue](https://www.enterprisedb.com/enterprisedb-support-portal). Please include the following information in your ticket so we can provide better support:

- Host OS and version
- Docker version (`docker version`)
- Output of `docker info`
- Version of this container (`docker inspect -f '{{ index .Config.Labels "version"'}} edb-postgres`)
- The command you used to run the container, and any relevant output you saw (masking any sensitive information)

# License

Copyright (c) 2020 EDB

For EDB Software including but not limited to: EDB Postgres Advanced Server,  EDB Postgres on Kubernetes, EDB Kubernetes Operator, EDB Postgres containers:
- If you download the software for evaluation purposes you agree to be bound by this [Limited Use License](https://www.enterprisedb.com/limited-use-license-v2-10).
- If you purchase an EDB Postgres Enterprise, EDB Postgres Standard, or EDB Postgres Developer subscription; you agree to be bound by this [EnterpriseDB Subscription,Support, and Services Agreement](https://www.enterprisedb.com/ba/license-support-services-v3-19).

