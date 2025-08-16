#!/bin/bash

INSTANCE_TYPE="t3.micro"
AVAILABILITY_ZONE="sa-east-1a"
AMI="ami-0d1b5a8c13042c939"
SECURITY_GROUP="sg-09c51fa83b004aad1"
KEY_NAME="girl"
VOLUME_SIZE=20
ROLE_NAME="SSM"

create_EC2() {
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI" \
        --instance-type "$INSTANCE_TYPE" \
        --placement AvailabilityZone="$AVAILABILITY_ZONE" \
        --key-name "$KEY_NAME" \
        --security-group-ids "$SECURITY_GROUP" \
        --iam-instance-profile Name="$ROLE_NAME" \
        --block-device-mappings "[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$VOLUME_SIZE}}]" \
        --user-data '#!/bin/bash
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo apt update -y' \
        --query "Instances[0].InstanceId" \
        --output text)

    export INSTANCE_ID
    echo "Instance created: $INSTANCE_ID"

    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
    echo "Instance is running, starting SSM session..."
    aws ssm start-session --target "$INSTANCE_ID"
}
