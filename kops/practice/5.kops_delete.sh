#!/bin/bash
export KOPS_STATE_STORE=s3://prac.konkas.tech
kops delete cluster prac.konkas.tech --yes