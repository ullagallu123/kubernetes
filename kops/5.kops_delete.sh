#!/bin/bash
export KOPS_STATE_STORE=s3://siva.cp.os
kops delete cluster test.ullagallu.cloud --yes