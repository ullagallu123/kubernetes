#!/bin/bash
export KOPS_STATE_STORE=s3://siva.cp.os
kops update cluster --name test.ullagallu.cloud --yes --admin