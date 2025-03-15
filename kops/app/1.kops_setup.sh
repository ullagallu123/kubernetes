#!/bin/bash

SPOT_ASG_MAX=2
SPOT_ASG_MIN=2
SPOT_INSTANCE_TYPE="t3a.small"

NODE_COUNT=2
NODE_SIZE="t3a.medium"
NODE_VOLUME_SIZE=20
NODE_ZONES="ap-south-1a,ap-south-1b"
CONTROL_PLANE_COUNT=1
CONTROL_PLANE_SIZE="t3a.medium"
CONTROL_PLANE_VOLUME_SIZE=20
CONTROL_PLANE_ZONES="ap-south-1a"
DNS_ZONE="bapatlas.site"
NETWORK_PLUGIN=calico
ETCD_VOLUME_SIZE=3

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
        --node-count="$NODE_COUNT" \
        --node-size="$NODE_SIZE" \
        --node-volume-size="$NODE_VOLUME_SIZE" \
        --control-plane-count="$CONTROL_PLANE_COUNT" \
        --control-plane-size="$CONTROL_PLANE_SIZE" \
        --control-plane-volume-size="$CONTROL_PLANE_VOLUME_SIZE" \
        --zones="$NODE_ZONES" \
        --control-plane-zones="$CONTROL_PLANE_ZONES" \
        --state="$KOPS_STATE_STORE" \
        --dns=public \
        --dns-zone="$DNS_ZONE" \
        --networking="$NETWORK_PLUGIN"
    print_message "Cluster creation initiated."
else
    print_message "Cluster already exists. Skipping creation."
fi

kops create secret sshpublickey admin -i ~/.ssh/id_ed25519.pub --name="$CLUSTER_NAME" --state="$KOPS_STATE_STORE"


kops get cluster --name="$CLUSTER_NAME" --state="$KOPS_STATE_STORE" -o yaml > cluster.yaml

# Function to print messages
print_message() {
    echo "$1"
}

# Check if all configurations are present, except awsLoadBalancerController
if ! grep -q "volumeSize: 3" cluster.yaml || \
   ! grep -q "metricsServer:" cluster.yaml || \
   ! grep -q "certManager:" cluster.yaml; then

    # Add volumeSize for the control plane instance group if missing
    if ! grep -q "volumeSize: 3" cluster.yaml; then
        sed -i '/instanceGroup: control-plane-ap-south-1b/a \ \ \ \ \ \ volumeSize: 3' cluster.yaml
    fi

    # Add metricsServer if missing
    if ! grep -q "metricsServer:" cluster.yaml; then
        sed -i '/spec:/a \ \ metricsServer:' cluster.yaml
        sed -i '/metricsServer:/a \ \ \ \ enabled: true' cluster.yaml
    fi

    # Add certManager if missing
    if ! grep -q "certManager:" cluster.yaml; then
        sed -i '/spec:/a \ \ certManager:' cluster.yaml
        sed -i '/certManager:/a \ \ \ \ enabled: true' cluster.yaml
    fi

    # Apply the updated configuration
    kops replace -f cluster.yaml

    print_message "Cluster configuration updated."
else
    print_message "No changes needed for the cluster configuration."
fi

# Cleanup
rm -rf cluster.yaml  # Removes only cluster.yaml; adjust if needed



# Fetch the cluster configuration and output to YAML file
kops get cluster --name="$CLUSTER_NAME" --state="$KOPS_STATE_STORE" -o yaml > cluster.yaml


# # Deleting default instance groups
# print_message "Deleting Default Instance Groups"
# if kops get ig nodes-ap-south-1a --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" &>/dev/null; then
#     kops delete ig nodes-ap-south-1a --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes
#     print_message "Deleted nodes-ap-south-1a."
# else
#     print_message "nodes-ap-south-1a already deleted or does not exist."
# fi

# if kops get ig nodes-ap-south-1b --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" &>/dev/null; then
#     kops delete ig nodes-ap-south-1b --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes
#     print_message "Deleted nodes-ap-south-1b."
# else
#     print_message "nodes-ap-south-1b already deleted or does not exist."
# fi

# # Creating Spot Instance Group
# print_message "Creating Spot Instance Group"
# if ! kops get ig spot-1 --name="$CLUSTER_NAME" &>/dev/null; then
#     kops toolbox instance-selector "spot-1" \
#         --usage-class spot --cluster-autoscaler \
#         --base-instance-type $SPOT_INSTANCE_TYPE \
#         --allow-list '^t3a.*' --gpus 0 \
#         --node-count-max $SPOT_ASG_MAX --node-count-min $SPOT_ASG_MIN \
#         --node-volume-size 20 \
#         --name="$CLUSTER_NAME"
#     print_message "Spot instance group created."
# else
#     print_message "Spot instance group already exists."
# fi

# Apply the changes in the Cloud
print_message "Applying Cluster Changes"
kops update cluster --name="$CLUSTER_NAME" --yes --admin



