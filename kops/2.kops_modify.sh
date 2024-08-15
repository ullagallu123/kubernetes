#!/bin/bash
export KOPS_STATE_STORE=s3://siva.cp.os
kops get cluster -o yaml > cluster.yaml
sed -i '/instanceGroup: control-plane-ap-south-1b/a \ \ \ \ \ \ volumeSize: 3' cluster.yaml
sed -i '/volumeSize: 2/a \ \ \ \ \ \ volumeType: gp3' cluster.yaml
kops replace -f cluster.yaml
rm -rf cluster.yaml
