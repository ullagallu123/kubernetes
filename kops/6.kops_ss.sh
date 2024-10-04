#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops edit ig --name=prod.konkas.tech  spot-1 &&
kops edit ig --name=prod.konkas.tech control-plane-ap-south-1b &&
kops update cluster --name prod.konkas.tech  --yes --admin




  