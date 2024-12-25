#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_message() {
    echo "=================================================================="
    echo "$1"
    echo "=================================================================="
}

# Set AWS profile
export AWS_PROFILE="eks-siva.bapatlas.site"

# Variables
ROLE_PREFIX="eksctl-ullagallu-nodegroup-ng1-NodeInstanceRole"
EBS_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
EXTERNAL_DNS_POLICY="arn:aws:iam::522814728660:policy/AllowExternalDNSUpdates"
EBS_CSI_DRIVER_KUSTOMIZE="github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.38"
CLUSTER_NAME="ullagallu-bapatlas.site"
ACCOUNT_NUMBER="522814728660"
IAM_POLICY="AWSLoadBalancerControllerIAMPolicy"
REGION="ap-south-1"

# Apply Kubernetes Metrics Server
print_message "Applying Kubernetes Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml || true

# Apply AWS EBS CSI Driver
print_message "Applying AWS EBS CSI Driver..."
kubectl apply -k "$EBS_CSI_DRIVER_KUSTOMIZE" || true

# Apply dynamic volume configuration
print_message "Applying Dynamic Volume Configuration..."
kubectl apply -f ../../k8s-volumes/dynamic-volume/ || true

# Create required namespaces
for ns in instana expense logging; do
    print_message "Ensuring namespace $ns exists..."
    kubectl get namespace $ns || kubectl create namespace $ns
done

# Create IAM policy for external-dns
print_message "Creating IAM policy for external-dns..."
if ! aws iam get-policy --policy-arn "$EXTERNAL_DNS_POLICY" >/dev/null 2>&1; then
    aws iam create-policy --policy-name "AllowExternalDNSUpdates" --policy-document file://AllowExternalDNSUpdates.json
else
    print_message "External DNS policy already exists. Skipping."
fi

# Find the IAM role matching the prefix
print_message "Finding IAM Role with prefix $ROLE_PREFIX..."
ROLE_NAME=$(aws iam list-roles --query "Roles[?starts_with(RoleName, \`$ROLE_PREFIX\`)].RoleName | [0]" --output text)

if [ -z "$ROLE_NAME" ] || [ "$ROLE_NAME" == "None" ]; then
    print_message "No IAM role found with the prefix $ROLE_PREFIX. Exiting."
    exit 1
fi

print_message "Attaching EBS CSI Driver policy to IAM Role $ROLE_NAME..."
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$EBS_POLICY_ARN" || true

# Install/Upgrade AWS Load Balancer Controller
print_message "Installing/Upgrading AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts || true
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=$CLUSTER_NAME \
    --namespace kube-system \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller || true

# Create IAM policy for AWS Load Balancer Controller
print_message "Ensuring AWS Load Balancer Controller IAM policy exists..."
if ! aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY >/dev/null 2>&1; then
    curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
    aws iam create-policy \
        --policy-name $IAM_POLICY \
        --policy-document file://iam-policy.json
else
    print_message "IAM policy for AWS Load Balancer Controller already exists. Skipping."
fi

# Create IAM Service Account for AWS Load Balancer Controller
print_message "Creating IAM Service Account for AWS Load Balancer Controller..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY \
    --approve || true

# Install/Upgrade External DNS
print_message "Installing/Upgrading External DNS Controller..."
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ || true
helm repo update

# Create IAM Service Account for External DNS
print_message "Creating IAM Service Account for External DNS..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --namespace=kube-system \
    --name=external-dns-controller \
    --attach-policy-arn=$EXTERNAL_DNS_POLICY \
    --approve || true

helm upgrade --install external-dns-controller external-dns/external-dns \
    --set clusterName=$CLUSTER_NAME \
    --namespace kube-system \
    --set serviceAccount.create=false \
    --set serviceAccount.name=external-dns-controller || true

print_message "Script execution completed successfully."

