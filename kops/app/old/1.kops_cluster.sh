#!/bin/bash
NIHARIKA=/home/ubuntu/kubernetes
NIHA=/home/ubuntu/kubernetes
NS1=instana
NS2=expense

print_message() {
    echo "$1"
}

print_message "Starting Cluster Creation.............................!"

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
    --state=$KOPS_STATE_STORE \
    --dns=public \
    --dns-zone=konkas.tech \
    --networking=cilium

echo "Deleting Dfault Instance groups...............................!"
kops delete ig nodes-ap-south-1a  --state=$KOPS_STATE_STORE --name=$CLUSTER_NAME --yes
kops delete ig nodes-ap-south-1b  --state=$KOPS_STATE_STORE --name=$CLUSTER_NAME --yes
   
echo "Creating Spot Instance Group..................................!"
kops toolbox instance-selector "spot-1" \
--usage-class spot --cluster-autoscaler \
--base-instance-type "t3a.medium" \
--allow-list '^t3a.*' --gpus 0 \
--node-count-max 10 --node-count-min 4 \
--node-volume-size 20 \
--name=$CLUSTER_NAME


print_message "Wait for 9 mins to Cluster Ready....................!"

for ((i=9; i>0; i--)); do
    echo "Cluster will be ready in $i minute(s)..."
    sleep 1m
done

print_message "Cluster is ready!"


print_message "Creating SC for instana and expense.................!"
kubectl apply -f $NIHARIKA/k8s-volumes/dynamic-volume/instana.yaml
kubectl apply -f $NIHARIKA/k8s-volumes/dynamic-volume/expense.yaml

print_message "Creating Namespaces for instana and expense.........!"
kubectl create ns instana
kubectl create ns expense

print_message "Creating Metric Server.............................!"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml


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
    print_message "Sleeping for $duration seconds..."
    sleep "$duration"
}

# Instana namespace deployments
print_message "Starting Instana Project: Mongo, MySQL, Rabbit, and Redis..."
apply_kubectl "$NIHA/instana/mongo" "$NS1"
apply_kubectl "$NIHA/instana/mysql" "$NS1"
apply_kubectl "$NIHA/instana/rabbit" "$NS1"
apply_kubectl "$NIHA/instana/redis" "$NS1"
print_message "Completed Instana Project: Mongo, MySQL, Rabbit, and Redis."
pause 60

# Catalogue, User, and Cart services
print_message "Starting Catalogue, User, and Cart..."
apply_kubectl "$NIHA/instana/catalogue" "$NS1"
apply_kubectl "$NIHA/instana/user" "$NS1"
apply_kubectl "$NIHA/instana/cart" "$NS1"
print_message "Completed Catalogue, User, and Cart."
pause 30

# Shipping service
print_message "Starting Shipping..."
apply_kubectl "$NIHA/instana/shipping" "$NS1"
print_message "Completed Shipping."
pause 20

# Payment service
print_message "Starting Payment..."
apply_kubectl "$NIHA/instana/payment" "$NS1"
print_message "Completed Payment."
pause 10

# Dispatch service
print_message "Starting Dispatch..."
apply_kubectl "$NIHA/instana/dispatch" "$NS1"
print_message "Completed Dispatch."
pause 10

# Web service
print_message "Starting Web..."
apply_kubectl "$NIHA/instana/web" "$NS1"
print_message "Completed Web."

# Expense namespace deployments
print_message "Starting Expense Project: MySQL..."
apply_kubectl "$NIHA/expense/mysql" "$NS2"
print_message "Completed MySQL."
pause 30

# Backend service
print_message "Starting Backend..."
apply_kubectl "$NIHA/expense/backend" "$NS2"
print_message "Completed Backend."

# Frontend service
print_message "Starting Frontend..."
apply_kubectl "$NIHA/expense/frontend" "$NS2"
print_message "Completed Frontend."

print_message "All deployments have been successfully applied!"
