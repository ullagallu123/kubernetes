kops create cluster \
    --cloud=aws \
    --name=prac.konkas.tech \
    --node-count=1 \
    --node-size=t3a.small \
    --node-volume-size=20 \
    --control-plane-count=1 \
    --control-plane-size=t3a.medium \
    --control-plane-volume-size=20 \
    --zones=ap-south-1a,ap-south-1b \
    --control-plane-zones=ap-south-1b \
    --state=s3://prac.konkas.tech \
    --dns=public \
    --dns-zone=konkas.tech \
    --networking=cilium
   

