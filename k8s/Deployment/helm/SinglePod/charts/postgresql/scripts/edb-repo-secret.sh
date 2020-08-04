#!/bin/bash

kubectl create secret docker-registry edb-regsecret --docker-server=containers.enterprisedb.com --docker-username=$1  --docker-password=$2 --docker-email=$3 -n $4
