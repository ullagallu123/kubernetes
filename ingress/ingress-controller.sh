#!/bin/bash

CLUSTER_NAME="ullagallu"
ACCOUNT_NUMBER="522814728660"
IAM_POLICY="AWSLoadBalancerControllerIAMPolicy"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=$CLUSTER_NAME -n kube-system --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json \
    --profile eks-siva.bapatlas.site

eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--region=$REGION \
--profile=eks-siva.bapatlas.site \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::$ACCOUNT_NUMBER:policy/$IAM_POLICY \
--approve