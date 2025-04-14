# K3s Cluster Setup with Multipass

A streamlined solution for creating a lightweight Kubernetes cluster using K3s and Multipass on macOS. Perfect for local development and testing.

## Prerequisites

- macOS (Apple Silicon or Intel)
- [Multipass](https://multipass.run/) installed (`brew install --cask multipass`)
-- After Installing multipass open the  app and allow access to local networks, this is required to ssh into the VMs.
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/) installed

## Post-Installation Setup

### macOS Network Permissions
After installing Multipass, you need to configure network access permissions:

1. Open **System Preferences**
2. Navigate to **Security & Privacy** > **Local Network**
3. Add the following applications:
   - Terminal app (if using CLI)
   - Visual Studio Code (if using the integrated terminal)

This step is required to allow proper communication with the Multipass VMs.

### Multipass Authentication
If you encounter the following error while running the script:

```bash
exec failed: The client is not authenticated with the Multipass service.
Please use 'multipass authenticate' before proceeding
```

You need to authenticate the Multipass service. Run the following command in your terminal:

```bash
multipass set local.passphrase="<your-passphrase>"
multipass authenticate "<your-passphrase>"
sudo multipass authenticate "<your-passphrase>"
```

## Features

- 🚀 Quick cluster setup with a single command
- ⚙️ Fully configurable cluster parameters via YAML
- 🔄 Easy scaling of worker nodes
- 🧹 Simple cleanup process
- 💪 Resource-efficient K3s implementation
- 🔒 Secure by default configuration

## Project Structure

```
k8s-multipass-setup/
├── scripts/
│   ├── create-cluster.sh    # Main cluster creation script
│   ├── destroy-cluster.sh  # Cluster cleanup script
│   └── utils.sh           # Utility functions
├── config/
│   └── cluster-config.yaml # Cluster configuration
└── templates/
    └── cloud-init.yaml    # Node initialization template
```

## Quick Start

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd k8s-multipass-setup
   ```

2. Make scripts executable:

   ```bash
   chmod +x scripts/*.sh
   ```

3. Configure your cluster:
   Edit `config/cluster-config.yaml` to match your requirements.

4. Create the cluster:

   ```bash
   ./scripts/create-cluster.sh
   ```

## Configuration

### Cluster Settings (via cluster-config.yaml)

```yaml
# Cluster Configuration
CLUSTER_NAME: "k3s-cluster"
NODE_COUNT: 2
MASTER_CPU: 2
MASTER_MEMORY: 2048
MASTER_DISK: 10
WORKER_CPU: 2
WORKER_MEMORY: 2048
WORKER_DISK: 10
K3S_VERSION: "v1.27.1+k3s1"

# Networking -  Not in use currently
POD_CIDR: "10.244.0.0/16"
SERVICE_CIDR: "10.96.0.0/16"

# Node Naming
MASTER_NODE_PREFIX: "master"
WORKER_NODE_PREFIX: "worker"
```

## Usage

### Verify Multipass Instance Status

```bash
multipass info
```

### Verify Cluster Status

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### Access Cluster

The setup automatically configures your local `kubectl` context. Your kubeconfig will be stored in `~/.kube/config`.

### Scale Worker Nodes

Adjust `NODE_COUNT` in `config/cluster-config.yaml` and run setup script again.

### Cleanup

To remove the cluster:

```bash
./scripts/destroy-cluster.sh
```

### Suspend or pause multipass instances

```bash
multipass suspend --all
```

### Resume instances

```bash
multipass start --all
```

## Troubleshooting

1. If nodes fail to start:

   ```bash
   multipass list
   multipass info <node-name>
   ```

2. Check K3s service status:

   ```bash
   sudo multipass exec <node-name> -- sudo systemctl status k3s
   ```

3. View K3s logs:

   ```bash
   sudo multipass exec <node-name> -- sudo journalctl -u k3s
   ```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Acknowledgments

- [K3s](https://k3s.io/) - Lightweight Kubernetes
- [Multipass](https://multipass.run/) - Ubuntu VMs on demand
- [Ubuntu](https://ubuntu.com/) - Base OS for nodes
