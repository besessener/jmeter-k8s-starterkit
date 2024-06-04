#!/usr/bin/env bash

# Source the namespace from the .tmp file
if [ -f ".tmp" ]; then
    source .tmp
else
    echo ".tmp file not found!"
    exit 1
fi

# Function to get the current master pod name
get_master_pod() {
    kubectl get pod -n "${namespace}" | grep jmeter-master | awk '{print $1}' 2>/dev/null
}

# Retrieve the master pod name
master_pod=$(get_master_pod)

# Check if the master pod exists initially
if [ -z "${master_pod}" ]; then
    echo "No master pod found in namespace ${namespace}."
    exit 1
fi

# Loop to constantly check if the master pod exists
while kubectl get pod -n "${namespace}" "${master_pod}" &> /dev/null; do
    echo "Pod ${master_pod} is still running in namespace ${namespace}."
    sleep 10  # Wait for 10 seconds before checking again
done

# Print a message when the pod no longer exists
echo "Pod ${master_pod} no longer exists in namespace ${namespace}."
