#!/bin/bash

# Variables
CLUSTER_NAME="app.konkas.tech"
SPOT_ASG_MAX=3
SPOT_ASG_MIN=2

# Function to print messages
print_message() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

# Cluster Creation
print_message "Starting Cluster Creation"
if ! kops get cluster --name="$CLUSTER_NAME" --state="$KOPS_STATE_STORE" &>/dev/null; then
    kops create cluster \
        --cloud=aws \
        --name="$CLUSTER_NAME" \
        --node-count=1 \
        --node-size=t3a.small \
        --node-volume-size=20 \
        --control-plane-count=1 \
        --control-plane-size=t3a.medium \
        --control-plane-volume-size=20 \
        --zones=ap-south-1a,ap-south-1b \
        --control-plane-zones=ap-south-1b \
        --state="$KOPS_STATE_STORE" \
        --dns=public \
        --dns-zone=konkas.tech \
        --networking=cilium
    print_message "Cluster creation initiated."
else
    print_message "Cluster already exists. Skipping creation."
fi

# Update cluster configuration if necessary
kops get cluster --name="$CLUSTER_NAME" --state="$KOPS_STATE_STORE" -o yaml > cluster.yaml
if ! grep -q "volumeSize: 3" cluster.yaml; then
    sed -i '/instanceGroup: control-plane-ap-south-1b/a \ \ \ \ \ \ volumeSize: 3' cluster.yaml
    kops replace -f cluster.yaml
    print_message "Cluster configuration updated."
else
    print_message "No changes needed for the cluster configuration."
fi
rm -rf cluster.yaml

# Deleting default instance groups
print_message "Deleting Default Instance Groups"
if kops get ig nodes-ap-south-1a --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" &>/dev/null; then
    kops delete ig nodes-ap-south-1a --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes
    print_message "Deleted nodes-ap-south-1a."
else
    print_message "nodes-ap-south-1a already deleted or does not exist."
fi

if kops get ig nodes-ap-south-1b --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" &>/dev/null; then
    kops delete ig nodes-ap-south-1b --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes
    print_message "Deleted nodes-ap-south-1b."
else
    print_message "nodes-ap-south-1b already deleted or does not exist."
fi

# Creating Spot Instance Group
print_message "Creating Spot Instance Group"
if ! kops get ig spot-1 --name="$CLUSTER_NAME" &>/dev/null; then
    kops toolbox instance-selector "spot-1" \
        --usage-class spot --cluster-autoscaler \
        --base-instance-type "t3a.medium" \
        --allow-list '^t3a.*' --gpus 0 \
        --node-count-max $SPOT_ASG_MAX --node-count-min $SPOT_ASG_MIN \
        --node-volume-size 20 \
        --name="$CLUSTER_NAME"
    print_message "Spot instance group created."
else
    print_message "Spot instance group already exists."
fi

# Apply the changes in the Cloud
print_message "Applying Cluster Changes"
kops update cluster --name="$CLUSTER_NAME" --yes --admin
