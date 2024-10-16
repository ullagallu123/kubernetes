#!/bin/bash

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

# Storage Class Creation
print_message "Creating Storage Classes for Instana and Expense"
kubectl apply -f "$NIHARIKA/k8s-volumes/dynamic-volume/instana.yaml"
kubectl apply -f "$NIHARIKA/k8s-volumes/dynamic-volume/expense.yaml"

# Namespace Creation
print_message "Creating Namespaces for Instana and Expense"
kubectl get ns "$NS1" &>/dev/null || kubectl create ns "$NS1"
kubectl get ns "$NS2" &>/dev/null || kubectl create ns "$NS2"

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
