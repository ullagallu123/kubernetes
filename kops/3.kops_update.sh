#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops update cluster --name prod.konkas.tech --yes --admin