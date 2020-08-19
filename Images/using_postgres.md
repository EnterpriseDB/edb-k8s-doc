


## Connecting to Postgres database

- Open a shell into the container:

        docker exec -it edb-postgres bash

- Log into the database:

        $PGBIN/psql -d postgres -U enterprisedb

## Running sample queries

        postgres=# select version();

        postgres=# create table mytable1(var1 text);

        postgres=# insert into mytable1 values ('hi from pg 11');

        postgres=# select * from mytable1;
                                                 