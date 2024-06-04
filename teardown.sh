#!/usr/bin/env bash

# Source the namespace from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

kubectl delete -f k8s/jmeter
kubectl delete all --all -n $namespace
kubectl delete all --all -n telegraf-operator
