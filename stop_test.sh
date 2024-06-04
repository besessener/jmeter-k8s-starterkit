#!/usr/bin/env bash

# Source the namespace from the .env file
if [ -f ".env" ]; then
    source .env
else
    echo ".env file not found!"
    exit 1
fi

# Function to get the current master pod name
get_master_pod() {
    kubectl get pod -n "${namespace}" | grep jmeter-master | awk '{print $1}' 2>/dev/null
}

# Retrieve the master pod name
master_pod=$(get_master_pod)

# Check if the master pod exists
if [ -z "${master_pod}" ]; then
    echo "No master pod found in namespace ${namespace}."
    exit 1
fi

# Execute the stoptest.sh script on the master pod
kubectl -n "${namespace}" exec -c jmmaster -ti "${master_pod}" -- bash /opt/jmeter/apache-jmeter/bin/stoptest.sh
