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

# Check if a master pod already exists
master_pod=$(get_master_pod)

if [ -z "${master_pod}" ]; then
    echo "No existing master pod found. Creating a new one."
    # Create a new master pod if none exists
    kubectl apply -f k8s/jmeter/jmeter-master.yaml

    # Wait until the new master pod appears
    while [ -z "${master_pod}" ]; do
        echo "Waiting for the master pod to be created..."
        sleep 10
        master_pod=$(get_master_pod)
    done
else
    echo "Existing master pod found: ${master_pod}"
fi

# Ensure the master pod is in the Running state
while true; do
    pod_status=$(kubectl get pod -n "${namespace}" "${master_pod}" -o jsonpath='{.status.phase}' 2>/dev/null)
    if [ "${pod_status}" == "Running" ]; then
        echo "Master pod ${master_pod} is in Running state."
        break
    else
        echo "Waiting for the master pod to be in Running state..."
        sleep 10
    fi
done

# Copy the report from the pod to the local machine
report_path="/report/result"
local_result_name="local_result_name"

# Check if the report directory exists in the pod
if kubectl exec -n "${namespace}" "${master_pod}" -- test -d "${report_path}"; then
    kubectl cp -n "${namespace}" "${master_pod}:${report_path}" "${PWD}/${local_result_name}"
    echo "Report has been copied to ${PWD}/${local_result_name}."
else
    echo "Report directory ${report_path} does not exist in the pod."
fi

# Delete the master pod resources
kubectl delete -f k8s/jmeter/jmeter-master.yaml
echo "Master pod resources have been deleted."