#!/bin/bash

check_dependencies() {
    # Check if multipass is installed
    if ! command -v multipass &> /dev/null; then
        echo "❌ Multipass is not installed. Please install it first."
        exit 1
    fi

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl is not installed. Please install it first."
        exit 1
    fi
}

wait_for_node() {
    local node=$1
    until multipass exec ${node} -- systemctl is-active --quiet k3s; do
        echo "Waiting for ${node} to be ready..."
        sleep 5
    done
}

read_config() {
    local config_file="${SCRIPT_DIR}/../config/cluster-config.yaml"
    if [ ! -f "$config_file" ]; then
        echo "❌ Config file not found: $config_file"
        exit 1
    fi

    # Debug: Print config file content
    echo "📋 Reading configuration from: $config_file"

    # Extract keys and values from YAML, ignoring comments
    while IFS=':' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        # Trim key and value
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Remove quotes from value if present
        value="${value%\"}"
        value="${value#\"}"

        # Skip if no value (section headers)
        [[ -z "$value" ]] && continue

        # Export the variable
        export "$key"="$value"
        echo "  → Set $key=$value"
    done < <(grep -v '^\s*$' "$config_file")
}