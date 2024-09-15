#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops toolbox instance-selector "spot-1" \
--usage-class spot --cluster-autoscaler \
--base-instance-type "t3a.medium" \
--allow-list '^t3a.*' --gpus 0 \
--node-count-max 10 --node-count-min 5 \
--name ullagallu.cloud

sleep 5

kops update cluster --name ullagallu.cloud --yes --admin
