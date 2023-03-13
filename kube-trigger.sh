#!/bin/sh
export CANARY_REPLICAS=1 && envsubst < train-schedule-kube-canary.yml | kubectl apply -f -
