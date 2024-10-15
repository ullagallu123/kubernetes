#!/bin/bash
export KOPS_STATE_STORE=s3://prac.konkas.tech
kops update cluster --name prac.konkas.tech --yes --admin