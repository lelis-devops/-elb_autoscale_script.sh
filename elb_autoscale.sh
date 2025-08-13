INSTANCE_TYPE="t3.micro"
AVAILABILITY_ZONE="sa-east-1a"
AMI="ami-020cba7c55df1f615"
FIREWALL="sg-084f770ea84b13ea4"
KEY_NAME="girl"
VOLUME_SIZE=8
SUBNET_ID="subnet-01aa6cb5fd6359d72"
LAUNCH_TEMPLATE_NAME="cloudx-launch-template"
create_lauch_template () {
     aws ec2 create-launch-template --launch-template-name "$LAUNCH_TEMPLATE_NAME" \
          --launch-template-data "{
            \"ImageId\":\"$AMI\",
            \"InstanceType\":\"$INSTANCE_TYPE\",
            \"KeyName\":\"$KEY_NAME\",
            \"SecurityGroupIds\":[\"$FIREWALL\"],
            \"BlockDeviceMappings\":[{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$VOLUME_SIZE}}]
        }" > /dev/null
    echo "Launch Template $LAUNCH_TEMPLATE_NAME criado."
}
}

create_target_group() {
    NAME_GROUP="XYN"
    PROTOCOL_IS="HTTPS"
    PORT_IS=443
    VPC_ID="vpc-049bb6de4e6d7efa3"
    VERSION_PROTOCOL="HTTP2"

    INTEGRITY_CHECK="HTTPS"
    INTEGRITY_PATH="/"

    DESTINY_GROUP=$(aws elbv2 create-target-group \
        --name "$NAME_GROUP" \
        --protocol "$PROTOCOL_IS" \
        --port "$PORT_IS" \
        --vpc-id "$VPC_ID" \
        --health-check-protocol "$INTEGRITY_CHECK" \
        --health-check-path "$INTEGRITY_PATH" \
        --query "TargetGroups[0].TargetGroupArn" \
        --output text)
    export DESTINY_GROUP
    aws elbv2 wait target-group-healthy --target-group-arn "$DESTINY_GROUP"
    echo "Target Group criado: $DESTINY_GROUP"

    aws elbv2 register-targets --target-group-arn "$DESTINY_GROUP" --targets Id="$INSTANCE_ID"
    echo "Instância $INSTANCE_ID registrada no Target Group $DESTINY_GROUP"
}

create_auto_scaling_group () {
    NAME_SCALING="CLOUDX"
    VPC_ID="vpc-049bb6de4e6d7efa3"
    SUBNETS="subnet-01aa6cb5fd6359d721d subnet-0f0081f5aaa61ec75 subnet-015a8fcb0db2f36 subnet-034ae4c177b2a921a subnet-0db22a7e82052001c"
    MIN_SIZE=20
    MAX_SIZE=40
    DESIRED_CAPACITY=20
    TARGET_GROUP_ARN="$DESTINY_GROUP"
 --instance-ids "$INSTANCE_ID"


   

    
    aws autoscaling create-auto-scaling-group \
        --auto-scaling-group-name "$NAME_SCALING" \
        --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=1" \
        --min-size $MIN_SIZE \
        --max-size $MAX_SIZE \
        --desired-capacity $DESIRED_CAPACITY \
        --vpc-zone-identifier "$SUBNETS" \
        --target-group-arns "$TARGET_GROUP_ARN"

    echo "Auto Scaling Group $NAME_SCALING criado com capacidade mínima $MIN_SIZE e máxima $MAX_SIZE."
}

