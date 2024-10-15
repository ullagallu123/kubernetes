#!/bin/bash
export KOPS_STATE_STORE=s3://prac.konkas.tech
time kops validate cluster --wait 10m
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
