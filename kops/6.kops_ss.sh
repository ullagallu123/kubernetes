#!/bin/bash
export KOPS_STATE_STORE=s3://siva.cp.os
kops edit ig --name=test.ullagallu.cloud  nodes-ap-south-1b &&
kops edit ig --name=test.ullagallu.cloud  control-plane-ap-south-1b &&
kops update cluster --name test.ullagallu.cloud  --yes --admin