#!/bin/bash

set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source utility functions
source "${SCRIPT_DIR}/utils.sh"

# Read configuration
read_config

# Check dependencies
check_dependencies

echo "🚀 Setting up K3s cluster with Multipass..."
echo "  • Master CPU: ${MASTER_CPU}"
echo "  • Master Memory: ${MASTER_MEMORY}"
echo "  • Master Disk: ${MASTER_DISK}G"
echo "  • Worker Count: ${NODE_COUNT}"
echo "  • Worker CPU: ${WORKER_CPU}"
echo "  • Worker Memory: ${WORKER_MEMORY}"
echo "  • Worker Disk: ${WORKER_DISK}G"


# Create master node
echo "📦 Creating master node..."
multipass launch "${UBUNTU_VERSION}" \
    --name "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}" \
    --cpus "${MASTER_CPU}" \
    --memory "${MASTER_MEMORY}M" \
    --disk "${MASTER_DISK}G" \
    --cloud-init "${SCRIPT_DIR}/../templates/cloud-init.yaml"

# Install K3s on master
echo "🔧 Installing K3s on master node..."
sudo multipass exec "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}" -- \
    bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} \
    K3S_KUBECONFIG_MODE=\"644\" \
    sh -"

# Get K3s token
TOKEN=$(sudo multipass exec "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}" sudo cat /var/lib/rancher/k3s/server/node-token)
MASTER_IP=$(sudo multipass info "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}" | grep IPv4 | awk '{print $2}')

# Create and join worker nodes
for i in $(seq 1 ${NODE_COUNT}); do
    echo "📦 Creating worker node ${i}..."
    multipass launch "${UBUNTU_VERSION}" \
        --name "${CLUSTER_NAME}-${WORKER_NODE_PREFIX}-${i}" \
        --cpus "${WORKER_CPU}" \
        --memory "${WORKER_MEMORY}M" \
        --disk "${WORKER_DISK}G" \
        --cloud-init "${SCRIPT_DIR}/../templates/cloud-init.yaml"

    echo "🔗 Joining worker node ${i} to cluster..."
    sudo multipass exec "${CLUSTER_NAME}-${WORKER_NODE_PREFIX}-${i}" -- \
        bash -c "curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 \
        K3S_TOKEN=${TOKEN} \
        INSTALL_K3S_VERSION=${K3S_VERSION} sh -"
done

# Label Worker Nodes
for i in $(seq 1 ${NODE_COUNT}); do
    echo "📦 Labelling worker node ${i}..."
    sudo multipass exec "${CLUSTER_NAME}-${WORKER_NODE_PREFIX}-${i}" -- \
        bash -c "kubectl label node ${CLUSTER_NAME}-${WORKER_NODE_PREFIX}-${i} node-role.kubernetes.io/worker=${CLUSTER_NAME}-${WORKER_NODE_PREFIX}"
done

# Copy kubeconfig
echo "📄 Copying kubeconfig to local machine..."
mkdir -p ~/.kube
sudo multipass exec "${CLUSTER_NAME}-${MASTER_NODE_PREFIX}" sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/config
sed -i '' "s/127.0.0.1/${MASTER_IP}/" ~/.kube/config

echo "✅ Cluster setup complete! Try 'kubectl get nodes' to verify."