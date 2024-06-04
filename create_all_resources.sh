#!/usr/bin/env bash

# Source the namespace from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

kubectl create -n $namespace -R -f k8s/