# Docker Desktop
Make sure you have docker desktop installed.

## EDB Repo Access Setup
1. Login: '$ docker login quay.io'

## Pulling Images Down

Pull: 'docker pull quay.io/enterprisedb/dev-postgres:10.13-ubi7'

Confrim image in local repo: 'docker image ls'

## Deploying

Depoly: 'docker run --name EDB-Postgres -e PG_PASSWORD=password -d quay.io/enterprisedb/dev-postgres:10.13-ubi7'

Confrim: 'docker ps'
