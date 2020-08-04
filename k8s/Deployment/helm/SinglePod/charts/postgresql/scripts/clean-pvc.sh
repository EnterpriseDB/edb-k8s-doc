#!/bin/bash
set -x

NAMESPACE="default"
if [[ "$1" == '' ]]; then
  echo "No namespace given setting to default"
else
  NAMESPACE=${1}
fi

PVCS="$(kubectl -n ${NAMESPACE} get pvc -o=jsonpath='{..metadata.name}')"

IFS=',' read -ra DISKS <<< "$PVCS"
for DISK in ${DISKS[@]}
do
  kubectl -n $NAMESPACE delete pvc $DISK
done
