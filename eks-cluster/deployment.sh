#!/bin/bash

export AWS_PROFILE="eks-siva.bapatlas.site"
# Function to print messages
print_message() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

# Variables
ROLE_PREFIX="eksctl-ullagallu-nodegroup-ng1-NodeInstanceRole"
POLICY_ARN="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
EBS_CSI_DRIVER_KUSTOMIZE="github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.38"


# Find the IAM role matching the prefix
print_message "Searching for IAM roles starting with prefix: $ROLE_PREFIX..."
ROLE_NAME=$(aws iam list-roles --query "Roles[?starts_with(RoleName, \`$ROLE_PREFIX\`)].RoleName | [0]" --output text)

if [ "$ROLE_NAME" == "None" ] || [ -z "$ROLE_NAME" ]; then
    print_message "No IAM role found with the prefix $ROLE_PREFIX. Exiting."
    exit 1
fi

print_message "IAM Role identified: $ROLE_NAME"

# Attach the policy to the identified role
print_message "Attaching policy $POLICY_ARN to IAM Role $ROLE_NAME..."
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"

if [ $? -eq 0 ]; then
    print_message "Policy $POLICY_ARN successfully attached to IAM Role $ROLE_NAME."
else
    print_message "Failed to attach policy $POLICY_ARN to IAM Role $ROLE_NAME."
    exit 1
fi

# Apply the AWS EBS CSI Driver manifests
print_message "Deploying the AWS EBS CSI Driver..."
kubectl apply -k "$EBS_CSI_DRIVER_KUSTOMIZE"

if [ $? -eq 0 ]; then
    print_message "AWS EBS CSI Driver deployment applied successfully."
else
    print_message "Failed to deploy AWS EBS CSI Driver. Exiting."
    exit 1
fi


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

# Prompt user to choose base directory
print_message "Choose the base directory:"
echo "1. Ubuntu (/home/ubuntu/kubernetes)"
echo "2. Alma (/home/alma/kubernetes)"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" -eq 1 ]; then
    BASE="/home/ubuntu/kubernetes"
elif [ "$choice" -eq 2 ]; then
    BASE="/home/alma/kubernetes"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Variables
NS1="instana"
NS2="expense"
print_message "Creating EBS CSI Driver Plugin"
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.38"


# Storage Class Creation
print_message "Creating Storage Classes for Instana and Expense"
kubectl apply -f "$BASE/k8s-volumes/dynamic-volume/instana.yaml"
kubectl apply -f "$BASE/k8s-volumes/dynamic-volume/expense.yaml"

# Namespace Creation
print_message "Creating Namespaces for Instana and Expense"
kubectl get ns "$NS1" &>/dev/null || kubectl create ns "$NS1"
kubectl get ns "$NS2" &>/dev/null || kubectl create ns "$NS2"

# Metrics Server Deployment
print_message "Deploying Metrics Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Instana Namespace Deployments
print_message "Deploying Services in Instana Namespace: Mongo, MySQL, Rabbit, and Redis"
apply_kubectl "$BASE/instana/mongo" "$NS1"
apply_kubectl "$BASE/instana/mysql" "$NS1"
apply_kubectl "$BASE/instana/rabbit" "$NS1"
apply_kubectl "$BASE/instana/redis" "$NS1"
pause 60

print_message "Deploying Services in Instana Namespace: Catalogue, User, and Cart"
apply_kubectl "$BASE/instana/catalogue" "$NS1"
apply_kubectl "$BASE/instana/user" "$NS1"
apply_kubectl "$BASE/instana/cart" "$NS1"
pause 30

print_message "Deploying Shipping Service in Instana Namespace"
apply_kubectl "$BASE/instana/shipping" "$NS1"
pause 20

print_message "Deploying Payment Service in Instana Namespace"
apply_kubectl "$BASE/instana/payment" "$NS1"
pause 10

print_message "Deploying Dispatch Service in Instana Namespace"
apply_kubectl "$BASE/instana/dispatch" "$NS1"
pause 10

print_message "Deploying Web Service in Instana Namespace"
apply_kubectl "$BASE/instana/web" "$NS1"

# Expense Namespace Deployments
print_message "Deploying Services in Expense Namespace: MySQL"
apply_kubectl "$BASE/expense/mysql" "$NS2"
pause 30

print_message "Deploying Backend Service in Expense Namespace"
apply_kubectl "$BASE/expense/backend" "$NS2"

print_message "Deploying Frontend Service in Expense Namespace"
apply_kubectl "$BASE/expense/frontend" "$NS2"

# Final message
print_message "All Deployments Have Been Successfully Applied!"
