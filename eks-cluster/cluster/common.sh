#!/bin/bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.32"
kubectl apply -f ../../k8s-volumes/dynamic-volume/
kubectl create ns instana
kubectl create ns expense
kubectl create ns logging

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
