kops delete ig nodes-ap-south-1a  --state=$KOPS_STATE_STORE --name=$CLUSTER_NAME --yes
kops delete ig nodes-ap-south-1b  --state=$KOPS_STATE_STORE --name=$CLUSTER_NAME --yes
