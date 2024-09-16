#!/bin/bash

# Variables
CLUSTER_NAME="siva"
REGION="ap-south-1"
ZONES="ap-south-1a,ap-south-1b"
NODEGROUP_NAME="siva-ng1"
NODE_TYPE="t3a.medium"
NODES=2
NODES_MIN=2
NODES_MAX=10
NODE_VOLUME_SIZE=20
SSH_PUBLIC_KEY="siva"
PROFILE="eks"
LOG_FILE="/tmp/eks_setup_$(date +%Y-%m-%d_%H-%M-%S).log"

# Function to calculate elapsed time
elapsed_time() {
    local start=$1
    local end=$2
    local elapsed=$(( end - start ))
    local minutes=$(( elapsed / 60 ))
    local seconds=$(( elapsed % 60 ))
    printf "Elapsed time: %d minutes and %d seconds\n" $minutes $seconds | tee -a "$LOG_FILE"
}

# Start timer
start_time=$(date +%s)

# Create EKS cluster
echo "Creating EKS cluster..." | tee -a "$LOG_FILE"
eksctl create cluster --name $CLUSTER_NAME \
                      --region $REGION \
                      --zones $ZONES \
                      --profile $PROFILE \
                      --without-nodegroup &>>"$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create EKS cluster." | tee -a "$LOG_FILE"
    exit 1
fi

# Associate IAM OIDC provider
echo "Associating IAM OIDC provider..." | tee -a "$LOG_FILE"
eksctl utils associate-iam-oidc-provider \
    --region $REGION \
    --cluster $CLUSTER_NAME \
    --profile $PROFILE \
    --approve &>>"$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to associate IAM OIDC provider." | tee -a "$LOG_FILE"
    exit 1
fi

# Record time after cluster creation
mid_time=$(date +%s)
elapsed_time $start_time $mid_time

# Create nodegroup
echo "Creating nodegroup..." | tee -a "$LOG_FILE"
eksctl create nodegroup --cluster=$CLUSTER_NAME \
                       --region=$REGION \
                       --name=$NODEGROUP_NAME \
                       --node-type=$NODE_TYPE \
                       --nodes=$NODES \
                       --nodes-min=$NODES_MIN \
                       --nodes-max=$NODES_MAX \
                       --node-volume-size=$NODE_VOLUME_SIZE \
                       --ssh-access \
                       --ssh-public-key=$SSH_PUBLIC_KEY \
                       --profile $PROFILE \
                       --managed \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --spot \
                       --alb-ingress-access &>>"$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create nodegroup." | tee -a "$LOG_FILE"
    exit 1
fi

# End timer
end_time=$(date +%s)

# Calculate and print total elapsed time
echo "Total time taken:" | tee -a "$LOG_FILE"
elapsed_time $start_time $end_time
