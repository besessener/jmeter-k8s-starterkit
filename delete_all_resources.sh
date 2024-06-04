#!/usr/bin/env bash

# Source the namespace from the .tmp file
if [ -f ".tmp" ]; then
    source .tmp
else
    echo ".tmp file not found!"
    exit 1
fi

kubectl delete all --all -n $namespace
