#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source utility functions
source "${SCRIPT_DIR}/utils.sh"

# Read configuration
read_config

echo "🧹 Cleaning up K3s cluster..."

# Delete worker nodes
for i in $(seq 1 ${NODE_COUNT}); do
    echo "Destroying worker node ${i}..."
    multipass delete "${CLUSTER_NAME}-${WORKER_NODE_PREFIX}-${i}"
done

# Delete master node
echo "Destroying master node..."
multipass delete "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}"

# Purge all deleted instances
multipass purge

# Remove kubeconfig if it exists
if [ -f ~/.kube/config ]; then
    echo "Removing kubeconfig..."
    rm ~/.kube/config
fi

echo "✅ Cluster cleanup complete!"