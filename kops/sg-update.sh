#!/bin/bash
read -p "Enter the type (app/prac): " TYPE

# Validate the input
if [[ "$TYPE" != "app" && "$TYPE" != "prac" ]]; then
    echo "Invalid input. Please enter 'app' or 'prac'."
    exit 1
fi

# Construct the Security Group name
SECURITY_GROUP_NAME="nodes.$TYPE.bapatlas.site"

# Find the Security Group ID
NODE_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" \
    --query "SecurityGroups[0].GroupId" --output text)

# Check if the Security Group was found
if [ -n "$NODE_SG_ID" ] && [ "$NODE_SG_ID" != "None" ]; then
    echo "Found Security Group: $NODE_SG_ID"
    aws ec2 authorize-security-group-ingress \
        --group-id "$NODE_SG_ID" \
        --protocol tcp \
        --port 30000-32767 \
        --cidr 0.0.0.0/0
    echo "NodePort range (30000-32767) added to Security Group: $NODE_SG_ID"
else
    echo "Security Group $SECURITY_GROUP_NAME not found."
fi