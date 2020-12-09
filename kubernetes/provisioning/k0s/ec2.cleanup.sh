#!/bin/bash

export AWS_PROFILE=moka-pos-experiment
export AWS_PAGER=""

instance_ids="$(aws ec2 describe-instances --filters \
      "Name=tag:Name,Values=node" \
      "Name=instance-state-name,Values=running" \
      --output text --query 'Reservations[].Instances[].InstanceId' | tr "\t" " ")"

echo "Issuing shutdown to worker nodes.. "

for id in ${instance_ids}; do
  aws ec2 terminate-instances \
    --instance-ids "${id}"

  aws ec2 wait instance-terminated \
    --instance-ids "${id}"
done