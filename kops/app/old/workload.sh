#!/bin/bash

export HOME=/home/ubuntu/kubernetes

print_message() {
    echo "$1"
}

print_message "Installing Metric Server Deployment..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --validate=false

# # Set environment variables
# export KOPS_STATE_STORE="s3://kops.ullagallu.cloud"
# export CLUSTER_NAME="app.konkas.tech"

# # Print environment variables
# echo "KOPS_STATE_STORE: $KOPS_STATE_STORE"
# echo "CLUSTER_NAME: $CLUSTER_NAME"

# Check the current context
# echo "Current kubectl context: $(kubectl config current-context)"

# # Validate the cluster
# kops validate cluster --state="$KOPS_STATE_STORE" --name="$CLUSTER_NAME" 

# Call the ID deletion script
# print_message "Deleting Instance Groups..."
# bash $HOME/kops/id.sh || { print_message "Failed to delete IG"; exit 1; }
# print_message "Completed IG Deletion!"

# # Call the Spot IG creation script
# print_message "Starting Spot IG Creation..."
# bash $HOME/kops/app/7.spot-id.sh || { print_message "Failed to create Spot IG"; exit 1; }
# print_message "Completed Spot IG Creation!"

# export AWS_PROFILE=siva
# export KOPS_STATE_STORE="s3://kops.ullagallu.cloud"
# export CLUSTER_NAME="app.konkas.tech"

print_message "Installing Metric Server Deployment..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

print_message "Installing sc for instana and expense projects..."
kubectl apply -f $HOME/k8s-volumes/dynamic-volume/instana.yaml
kubectl apply -f $HOME/k8s-volumes/dynamic-volume/expense.yaml

print_message "Starting installing instance project..."
# Deploying other resources
kubectl apply -f $HOME/instana/mysql 
sleep 20
kubectl apply -f $HOME/instana/mon* 
sleep 20
kubectl apply -f $HOME/instana/rabbit 
sleep 20
kubectl apply -f $HOME/instana/redis 
sleep 60
kubectl apply -f $HOME/instana/catalo*  -f $HOME/instana/user -f $HOME/instana/cart --validate=false
sleep 5
kubectl apply -f $HOME/instana/shippin* --validate=false
sleep 40
kubectl apply -f $HOME/instana/payment --validate=false -f $HOME/instana/dispatch --validate=false
sleep 5 
kubectl apply -f $HOME/instana/web --validate=false

print_message "Instana Deployment Was Successful!"
print_message "Starting expense Project Deployment..."
kubectl apply -f $HOME/expense/mysql --validate=false
sleep 60
kubectl apply -f $HOME/expense/backend --validate=false
sleep 30
kubectl apply -f $HOME/expense/frontend --validate=false

print_message "Completed expense project Deployment!"
