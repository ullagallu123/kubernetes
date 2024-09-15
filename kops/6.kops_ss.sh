#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops edit ig --name=ullagallu.cloud  spot-1 &&
kops edit ig --name=ullagallu.cloud  control-plane-ap-south-1b &&
kops update cluster --name ullagallu.cloud  --yes --admin




