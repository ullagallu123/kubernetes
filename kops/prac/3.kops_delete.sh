#!/bin/bash
kops delete cluster --state=$KOPS_STATE_STORE --name $CLUSTER_NAME --yes