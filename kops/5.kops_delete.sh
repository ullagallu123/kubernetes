#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops delete cluster ullagallu.cloud --yes