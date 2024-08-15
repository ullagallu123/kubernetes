kops create cluster \
    --cloud=aws \
    --name=test.ullagallu.cloud \
    --node-count=3 \
    --node-size=t3a.medium \
    --node-volume-size=20 \
    --control-plane-count=1 \
    --control-plane-size=t3a.medium \
    --control-plane-volume-size=20 \
    --zones=ap-south-1b \
    --state=s3://siva.cp.os \
    --dns=public \
    --dns-zone=test.ullagallu.cloud \
    --networking=cilium
   

