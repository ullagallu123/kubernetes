#!/bin/bash

# Create Spot Instance Group
echo "Creating Spot Instance Group..."
kops toolbox instance-selector "spot-1" \
--usage-class spot --cluster-autoscaler \
--base-instance-type "t3a.medium" \
--allow-list '^t3a.*' --gpus 0 \
--node-count-max 10 --node-count-min 4 \
--node-volume-size 20 \
--name=$CLUSTER_NAME

# Sleep for 5 seconds before updating the cluster
echo "Sleeping for 5 seconds..."
sleep 5

# Update the cluster
kops update cluster --name=$CLUSTER_NAME --yes --admin

