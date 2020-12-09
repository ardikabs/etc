#!/bin/bash

export AWS_PROFILE=moka-pos-experiment
export AWS_PAGER=""
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 \
  --filters \
  'Name=root-device-type,Values=ebs' \
  'Name=architecture,Values=x86_64' \
  'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*' \
  | jq -r '.Images|sort_by(.Name)[-1]|.ImageId')

for i in $(seq 4); do
  echo "node-${i} creating ..."
  instance_id=$(aws ec2 run-instances \
    --associate-public-ip-address \
    --image-id "${IMAGE_ID}" \
    --count 1 \
    --instance-type t2.medium \
    --security-group-ids sg-0f5618a4288250326 \
    --subnet-id subnet-0c8508431f14d6e92 \
    --block-device-mappings='{"DeviceName": "/dev/sda1", "Ebs": { "VolumeSize": 15 }, "NoDevice": "" }' \
    --output text --query 'Instances[].InstanceId')
  aws ec2 modify-instance-attribute --instance-id "${instance_id}" --no-source-dest-check
  aws ec2 create-tags --resources "${instance_id}" --tags "Key=Name,Value=node"
  echo "node-${i} created"
done