# #!/bin/bash

# # Exit immediately if a command exits with a non-zero status
# set -e

# # Function to print messages
# print_message() {
#     echo "=================================================================="
#     echo "$1"
#     echo "=================================================================="
# }

# # Set AWS profile
# export AWS_PROFILE="eks-siva.bapatlas.site"

# # Variables
# ROLE_PREFIX="eksctl-ullagallu-bapatlas-site-nod-NodeInstanceRole"
# EBS_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# EXTERNAL_DNS_POLICY="arn:aws:iam::522814728660:policy/AllowExternalDNSUpdates"
# EBS_CSI_DRIVER_KUSTOMIZE="github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.38"
# CLUSTER_NAME="ullagallu-bapatlas-site"
# ACCOUNT_NUMBER="522814728660"
# IAM_POLICY="AWSLoadBalancerControllerIAMPolicy"
# REGION="ap-south-1"

# # Apply Kubernetes Metrics Server
# print_message "Applying Kubernetes Metrics Server..."
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml || true

# # Apply AWS EBS CSI Driver
# print_message "Applying AWS EBS CSI Driver..."
# kubectl apply -k "$EBS_CSI_DRIVER_KUSTOMIZE" || true

# # Apply dynamic volume configuration
# print_message "Applying Dynamic Volume Configuration..."
# kubectl apply -f ../../k8s-volumes/dynamic-volume/ || true

# # Create required namespaces
# for ns in instana expense monitoring; do
#     print_message "Ensuring namespace $ns exists..."
#     kubectl get namespace $ns || kubectl create namespace $ns
# done

# # Create IAM policy for external-dns
# print_message "Creating IAM policy for external-dns..."
# if ! aws iam get-policy --policy-arn "$EXTERNAL_DNS_POLICY" >/dev/null 2>&1; then
#     aws iam create-policy --policy-name "AllowExternalDNSUpdates" --policy-document file://AllowExternalDNSUpdates.json
# else
#     print_message "External DNS policy already exists. Skipping."
# fi

# # Find the IAM role matching the prefix
# print_message "Finding IAM Role with prefix $ROLE_PREFIX..."
# ROLE_NAME=$(aws iam list-roles --query "Roles[?starts_with(RoleName, \`$ROLE_PREFIX\`)].RoleName | [0]" --output text)

# if [ -z "$ROLE_NAME" ] || [ "$ROLE_NAME" == "None" ]; then
#     print_message "No IAM role found with the prefix $ROLE_PREFIX. Exiting."
#     exit 1
# fi

# print_message "Attaching EBS CSI Driver policy to IAM Role $ROLE_NAME..."
# aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$EBS_POLICY_ARN" || true

# # Install/Upgrade AWS Load Balancer Controller
# print_message "Installing/Upgrading AWS Load Balancer Controller..."
# helm repo add eks https://aws.github.io/eks-charts || true
# helm repo update

# helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
#     --set clusterName=$CLUSTER_NAME \
#     --namespace kube-system \
#     --set serviceAccount.create=false \
#     --set serviceAccount.name=aws-load-balancer-controller || true

# # Create IAM policy for AWS Load Balancer Controller
# print_message "Ensuring AWS Load Balancer Controller IAM policy exists..."
# if ! aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY >/dev/null 2>&1; then
#     curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
#     aws iam create-policy \
#         --policy-name $IAM_POLICY \
#         --policy-document file://iam-policy.json
# else
#     print_message "IAM policy for AWS Load Balancer Controller already exists. Skipping."
# fi

# # Create IAM Service Account for AWS Load Balancer Controller
# print_message "Creating IAM Service Account for AWS Load Balancer Controller..."
# eksctl create iamserviceaccount \
#     --cluster=$CLUSTER_NAME \
#     --region=$REGION \
#     --namespace=kube-system \
#     --name=aws-load-balancer-controller \
#     --attach-policy-arn=arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY \
#     --approve || true

# # Install/Upgrade External DNS
# print_message "Installing/Upgrading External DNS Controller..."
# helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ || true
# helm repo update

# # Create IAM Service Account for External DNS
# print_message "Creating IAM Service Account for External DNS..."
# eksctl create iamserviceaccount \
#     --cluster=$CLUSTER_NAME \
#     --region=$REGION \
#     --namespace=kube-system \
#     --name=external-dns-controller \
#     --attach-policy-arn=$EXTERNAL_DNS_POLICY \
#     --approve || true

# helm upgrade --install external-dns-controller external-dns/external-dns \
#     --set clusterName=$CLUSTER_NAME \
#     --namespace kube-system \
#     --set serviceAccount.create=false \
#     --set serviceAccount.name=external-dns-controller || true

# print_message "Install prometheus-operator..."
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update
# helm insatll prometheus-operator prometheus-community/kube-prometheus-stack -n monitoring

# kubectl apply -f monitoring-ingress.yaml
# - whereever this script is there same for folder monitoring-ingress.yaml should be there

# print_message "Script execution completed successfully."

# - Make it idempotnent


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
ROLE_PREFIX="eksctl-ullagallu-bapatlas-site-nod-NodeInstanceRole"
EBS_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
EXTERNAL_DNS_POLICY="arn:aws:iam::522814728660:policy/AllowExternalDNSUpdates"
EBS_CSI_DRIVER_KUSTOMIZE="github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.38"
CLUSTER_NAME="ullagallu-bapatlas-site"
ACCOUNT_NUMBER="522814728660"
IAM_POLICY="AWSLoadBalancerControllerIAMPolicy"
REGION="ap-south-1"
MONITORING_INGRESS_FILE="monitoring-ingress.yaml"

# Apply Kubernetes Metrics Server
print_message "Applying Kubernetes Metrics Server..."
if ! kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
else
    print_message "Metrics Server already applied. Skipping."
fi

# Apply AWS EBS CSI Driver
print_message "Applying AWS EBS CSI Driver..."
kubectl apply -k "$EBS_CSI_DRIVER_KUSTOMIZE"

# Apply dynamic volume configuration
print_message "Applying Dynamic Volume Configuration..."
kubectl apply -f ../../k8s-volumes/dynamic-volume/

# Create required namespaces
for ns in instana expense monitoring; do
    print_message "Ensuring namespace $ns exists..."
    kubectl get namespace $ns || kubectl create namespace $ns
done

# Create IAM policy for external-dns
print_message "Ensuring IAM policy for external-dns exists..."
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

print_message "Ensuring EBS CSI Driver policy is attached to IAM Role $ROLE_NAME..."
if ! aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[?PolicyArn=='$EBS_POLICY_ARN']" --output text | grep -q "$EBS_POLICY_ARN"; then
    aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$EBS_POLICY_ARN"
else
    print_message "EBS CSI Driver policy already attached. Skipping."
fi

# Install/Upgrade AWS Load Balancer Controller
print_message "Installing/Upgrading AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=$CLUSTER_NAME \
    --namespace kube-system \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

# Create IAM policy for AWS Load Balancer Controller
print_message "Ensuring AWS Load Balancer Controller IAM policy exists..."
if ! aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY >/dev/null 2>&1; then
    curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
    aws iam create-policy --policy-name $IAM_POLICY --policy-document file://iam-policy.json
else
    print_message "AWS Load Balancer Controller IAM policy already exists. Skipping."
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
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

print_message "Creating IAM Service Account for External DNS..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --namespace=kube-system \
    --name=external-dns-controller \
    --attach-policy-arn=$EXTERNAL_DNS_POLICY \
    --approve || true

helm upgrade --install external-dns-controller external-dns/external-dns \
    --namespace kube-system \
    --set serviceAccount.create=false \
    --set serviceAccount.name=external-dns-controller

# Install Prometheus Operator
print_message "Installing/Upgrading Prometheus Operator..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus-operator prometheus-community/kube-prometheus-stack -n monitoring || true

# Apply monitoring ingress
if [ -f "$MONITORING_INGRESS_FILE" ]; then
    print_message "Applying monitoring ingress..."
    kubectl apply -f "$MONITORING_INGRESS_FILE"
else
    print_message "Monitoring ingress file $MONITORING_INGRESS_FILE not found. Skipping."
fi

print_message "Script execution completed successfully."
