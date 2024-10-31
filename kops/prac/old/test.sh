#!/bin/bash
- Make my Script More Idempotent
# Variables
NIHARIKA="/home/ubuntu/kubernetes"
NIHA="/home/ubuntu/kubernetes"
NS1="instana"
NS2="expense"

# Function to print messages
print_message() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

# Function to apply Kubernetes manifests with error checking
apply_kubectl() {
    local file_path=$1
    local namespace=$2

    kubectl apply -f "$file_path" -n "$namespace"
    if [ $? -eq 0 ]; then
        print_message "Successfully applied $file_path in namespace $namespace."
    else
        print_message "Failed to apply $file_path in namespace $namespace."
        exit 1
    fi
}

# Function for sleep with a message
pause() {
    local duration=$1
    print_message "Pausing for $duration seconds..."
    sleep "$duration"
}

# Cluster Creation
print_message "Starting Cluster Creation"
kops create cluster \
    --cloud=aws \
    --name=app.konkas.tech \
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

- If cluster is already created skip cluster creation 

# Deleting default instance groups
print_message "Deleting Default Instance Groups"
kops delete ig nodes-ap-south-1a --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes
kops delete ig nodes-ap-south-1b --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" --yes

- If nodes was already deleted nodes-ap-south-1a nodes-ap-south-1b skip

# Creating Spot Instance Group
print_message "Creating Spot Instance Group"
kops toolbox instance-selector "spot-1" \
    --usage-class spot --cluster-autoscaler \
    --base-instance-type "t3a.medium" \
    --allow-list '^t3a.*' --gpus 0 \
    --node-count-max 10 --node-count-min 4 \
    --node-volume-size 20 \
    --name="$CLUSTER_NAME"



print_message "Apply the changes in the Cloud"
kops update cluster  --name=$CLUSTER_NAME  --yes --admin

# Wait for the cluster to be ready

kops validate cluster If it is true then only run the creating Storage Classes to remainning otherwise dont create
print_message "Waiting for 9 minutes for Cluster to be Ready"
for ((i=9; i>0; i--)); do
    echo "Cluster will be ready in $i minute(s)..."
    sleep 1m
done
print_message "Cluster is Ready!"

# Storage Class Creation
print_message "Creating Storage Classes for Instana and Expense"
kubectl apply -f "$NIHARIKA/k8s-volumes/dynamic-volume/instana.yaml"
kubectl apply -f "$NIHARIKA/k8s-volumes/dynamic-volume/expense.yaml"

# Namespace Creation
print_message "Creating Namespaces for Instana and Expense"
kubectl create ns "$NS1"
kubectl create ns "$NS2"

# Metrics Server Deployment
print_message "Deploying Metrics Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Instana Namespace Deployments
print_message "Deploying Services in Instana Namespace: Mongo, MySQL, Rabbit, and Redis"
apply_kubectl "$NIHA/instana/mongo" "$NS1"
apply_kubectl "$NIHA/instana/mysql" "$NS1"
apply_kubectl "$NIHA/instana/rabbit" "$NS1"
apply_kubectl "$NIHA/instana/redis" "$NS1"
pause 60

print_message "Deploying Services in Instana Namespace: Catalogue, User, and Cart"
apply_kubectl "$NIHA/instana/catalogue" "$NS1"
apply_kubectl "$NIHA/instana/user" "$NS1"
apply_kubectl "$NIHA/instana/cart" "$NS1"
pause 30

print_message "Deploying Shipping Service in Instana Namespace"
apply_kubectl "$NIHA/instana/shipping" "$NS1"
pause 20

print_message "Deploying Payment Service in Instana Namespace"
apply_kubectl "$NIHA/instana/payment" "$NS1"
pause 10

print_message "Deploying Dispatch Service in Instana Namespace"
apply_kubectl "$NIHA/instana/dispatch" "$NS1"
pause 10

print_message "Deploying Web Service in Instana Namespace"
apply_kubectl "$NIHA/instana/web" "$NS1"

# Expense Namespace Deployments
print_message "Deploying Services in Expense Namespace: MySQL"
apply_kubectl "$NIHA/expense/mysql" "$NS2"
pause 30

print_message "Deploying Backend Service in Expense Namespace"
apply_kubectl "$NIHA/expense/backend" "$NS2"

print_message "Deploying Frontend Service in Expense Namespace"
apply_kubectl "$NIHA/expense/frontend" "$NS2"

# Final message
print_message "All Deployments Have Been Successfully Applied!"
