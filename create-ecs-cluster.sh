#!/bin/bash

# Exit on any error
set -e

JQ="jq --raw-output --exit-status"
ECS_AMI_ID=ami-a99d8ad5
ECR_REPOSITORY=quake3/server
ECS_SERVICE="q3a-server-service"
configure_aws_cli(){
	aws --version
	aws configure set default.region ap-northeast-1
	aws configure set default.output json
}

create_repository() {
	if REPOSITORY_NAME=$(aws ecr create-repository --repository-name ${ECR_REPOSITORY} | $JQ '.repository.repositoryName'); then
		echo "REPOSITORY_NAME: ${REPOSITORY_NAME}"
	else
		echo "Failed to Create REPOSITORY"
		exit 1
	fi
}

create_cluster() {

	if CLUSTER_ARN=$(aws ecs create-cluster --cluster-name q3a-server-cluster | $JQ '.cluster.clusterArn'); then
		echo "CLUSTER_ARN: ${CLUSTER_ARN}"
	else
		echo "Failed to Create Cluster"
		exit 1
	fi

	make_ec2instace_userdata
	ec2_startup
	make_task_def
	register_definition
	make_service_input_json
	register_service
	exit 0
}

make_task_def(){
	task_template='[
		{
			"name": "q3a-server",
			"image": "%s.dkr.ecr.ap-northeast-1.amazonaws.com/%s:latest",
			"essential": true,
			"memory": 200,
			"cpu": 10,
			"portMappings": [
				{
					"containerPort": 27960,
					"hostPort": 27960,
					"protocol": "udp"
				}
			],
			"command": [
				"server"
			]
		}
	]'

	task_def=$(printf "$task_template" ${AWS_ACCOUNT_ID} ${ECR_REPOSITORY})
}

register_definition() {

	if TASK_DEFINITION_ARN=$(aws ecs register-task-definition --container-definitions "$task_def" --family q3a-server-task | $JQ '.taskDefinition.taskDefinitionArn'); then
		echo "TASK_DEFINITION_ARN: $TASK_DEFINITION_ARN"
	else
		echo "Failed to register task definition"
		exit 1
	fi
}

make_service_input_json() {


cat << EOF > input-service.json
{
	"cluster": "${CLUSTER_ARN}",
	"serviceName": "${ECS_SERVICE}",
	"taskDefinition": "${TASK_DEFINITION_ARN}",
	"schedulingStrategy": "DAEMON"
}
EOF
}

register_service() {

	if SERVICE_ARN=$(aws ecs create-service --cli-input-json file://input-service.json | $JQ '.service.serviceArn'); then
		echo "SERVICE_ARN: $SERVICE_ARN"
	else
		echo "Failed to register service"
		exit 1
	fi
}

make_ec2instace_userdata(){
cat << EOF > userdata.sh
Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Install nfs-utils
cloud-init-per once yum_update yum update -y
cloud-init-per once install_nfs_utils yum install -y nfs-utils

cloud-init-per once docker_options echo 'OPTIONS="\${OPTIONS} --storage-opt dm.basesize=30G"' >> /etc/sysconfig/docker

#!/bin/bash
# Set any ECS agent configuration options
echo "ECS_CLUSTER=${CLUSTER_ARN}" >> /etc/ecs/ecs.config

--==BOUNDARY==--
EOF
}

ec2_startup() {

	if INSTANCE_ID=$(aws ec2 run-instances \
	  --image-id ${ECS_AMI_ID} \
	  --security-group-ids ${AWS_SECURITYGROUPID} \
	  --key-name ${AWS_KEY_NAME} \
	  --user-data "file://userdata.sh" \
	  --iam-instance-profile Name="ecsInstanceRole" \
	  --instance-type t2.micro \
	  --block-device-mappings "[{\"DeviceName\":\"/dev/xvdcz\",\"Ebs\":{\"VolumeSize\":30,\"DeleteOnTermination\":true}}]" \
	  --count 1 \
	 | $JQ '.Instances[0].InstanceId'); then
		echo "INSTANCE_ID: ${INSTANCE_ID}"
		aws ec2 create-tags --resources ${INSTANCE_ID} --tags Key=Name,Value=ecs-task-instance
	else
		echo "Failed to ec2_startup"
		exit 1
	fi
}

configure_aws_cli
create_repository
create_cluster
