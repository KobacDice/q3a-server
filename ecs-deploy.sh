#!/usr/bin/env bash

# Exit on any error
set -e

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

configure_aws_cli(){
	aws --version
	aws configure set default.region ap-northeast-1
	aws configure set default.output json
}

deploy_cluster() {

	family="q3a-server-task"

	make_task_def
	register_definition
	if [[ $(aws ecs update-service --cluster q3a-server-cluster --service q3a-server-service --task-definition $revision | \
		$JQ '.service.taskDefinition') != $revision ]]; then
		echo "Error updating service."
		return 1
	fi

	# wait for older revisions to disappear
	# not really necessary, but nice for demos
	for attempt in {1..3000}; do
		if stale=$(aws ecs describe-services --cluster q3a-server-cluster --services q3a-server-service | \
			$JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
			echo "Waiting for stale deployments:"
			echo "$stale"
			sleep 5
		else
			echo "Deployed!"
			return 0
		fi
	done
	echo "Service update took too long."
	return 1
}

make_task_def(){
	task_template='[
		{
			"name": "q3a-server",
			"image": "%s.dkr.ecr.ap-northeast-1.amazonaws.com/quake3/server:latest",
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

	task_def=$(printf "$task_template" ${AWS_ACCOUNT_ID})
}

register_definition() {

	if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
		echo "Revision: $revision"
	else
		echo "Failed to register task definition"
		return 1
	fi
}

configure_aws_cli
deploy_cluster
