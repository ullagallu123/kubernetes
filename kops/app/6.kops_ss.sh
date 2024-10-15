#!/bin/bash
kops edit ig  --name=$CLUSTER_NAME  spot-1 &&
kops edit ig  --name=$CLUSTER_NAME control-plane-ap-south-1b &&
kops update cluster  --name=$CLUSTER_NAME  --yes --admin




  