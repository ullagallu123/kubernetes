#!/bin/bash

CLUSTER_NAME="ullagallu.cloud"
ACCOUNT_NUMBER="427366301535"
IAM_POLICY="AWSLoadBalancerControllerIAMPolicy"
REGION="ap-south-1"

kubectl create serviceaccount aws-load-balancer-controller -n kube-system

# eksctl create iamserviceaccount \
# --cluster=$CLUSTER_NAME \
# --namespace=kube-system \
# --name=aws-load-balancer-controller \
# --attach-policy-arn=arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY \
# --override-existing-serviceaccounts \
# --region $REGION \
# --approve


helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=ullagallu.cloud --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

kubectl get sa aws-load-balancer-controller -n kube-system -o yaml