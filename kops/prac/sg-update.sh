#!/bin/bash

SECURITY_GROUP_NAME="nodes.prac.bapatlas.site"
NODE_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" \
    --query "SecurityGroups[0].GroupId" --output text)

if [ -n "$NODE_SG_ID" ]; then
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
