#!/bin/bash
INSTANCE_TYPE="t3.micro"
AMI="ami-020cba7c55df1f615"
KEY_NAME="girl"
FIREWALL="sg-0ac76ae450b269e20"
VOLUME_SIZE=8
LAUNCH_TEMPLATE_NAME="cloudx-launch-template"
TARGET_GROUP_NAME="XYN"
LOAD_BALANCER_NAME="cloudx-nlb"
AUTO_SCALING_GROUP_NAME="CLOUDX"
VPC_ID="vpc-049bb6de4e6d7efa3"
SUBNETS="subnet-01aa6cb5fd6359d721d subnet-0f0081f5aaa61ec75 subnet-015a8fcb0db2f36 subnet-034ae4c177b2a921a subnet-0db22a7e82052001c"
ZONE_NAME="interno.local"


create_launch_template() {
    USER_DATA=$(base64 -w0 <<EOF
#!/bin/bash
yum update -y
yum install -y mysql
systemctl enable mysqld
systemctl start mysqld
EOF
)

    aws ec2 create-launch-template \
        --launch-template-name "$LAUNCH_TEMPLATE_NAME" \
        --launch-template-data "{
            \"ImageId\": \"$AMI\",
            \"InstanceType\": \"$INSTANCE_TYPE\",
            \"KeyName\": \"$KEY_NAME\",
            \"SecurityGroupIds\": [\"$FIREWALL\"],
            \"BlockDeviceMappings\": [{\"DeviceName\": \"/dev/sdf\", \"Ebs\": {\"VolumeSize\": $VOLUME_SIZE}}],
            \"UserData\": \"$USER_DATA\"
        }" > /dev/null

    echo "Launch Template criado: $LAUNCH_TEMPLATE_NAME"
}


create_target_group() {
    DESTINY_GROUP=$(aws elbv2 create-target-group \
        --name "$TARGET_GROUP_NAME" \
        --protocol TCP \
        --port 3306 \
        --vpc-id "$VPC_ID" \
        --target-type instance \
        --query "TargetGroups[0].TargetGroupArn" \
        --output text)
    export DESTINY_GROUP
    echo "Target Group criado: $DESTINY_GROUP"


reate_load_balancer() {
    NLB_ARN=$(aws elbv2 create-load-balancer \
        --name "$LOAD_BALANCER_NAME" \
        --type network \
        --subnets $SUBNETS \
        --query "LoadBalancers[0].LoadBalancerArn" \
        --output text)

    aws elbv2 create-listener \
        --load-balancer-arn "$NLB_ARN" \
        --protocol TCP \
        --port 3306 \


    echo "Network Load Balancer criado e associado ao Target Group."

    
}








create_launch_template
create_target_group
create_load_balancer
create_auto_scaling_group
create_private_hosted_zone
