#!/bin/bash
export KOPS_STATE_STORE=s3://prac.konkas.tech
kops edit ig --name=prac.konkas.tech  spot-1 &&
kops edit ig --name=prac.konkas.tech control-plane-ap-south-1b &&
kops update cluster --name prac.konkas.tech  --yes --admin




  