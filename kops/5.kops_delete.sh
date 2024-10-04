#!/bin/bash
export KOPS_STATE_STORE=s3://kops.ullagallu.cloud
kops delete cluster prod.konkas.tech --yes