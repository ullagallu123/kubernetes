#!/bin/bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.32"
kubectl apply -f ../k8s-volumes/dynamic-volume/
kubectl create ns instana
kubectl create ns expense
kubectl create ns logging
