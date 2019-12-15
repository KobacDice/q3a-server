#!/bin/bash

# Exit on any error
set -e

CLUSTER_NAME="q3a-server-cluster"
CLOUDSDK_COMPUTE_ZONE="asia-northeast1-a"
REGISTRY_NAME="q3a-server"

# Setup Google Cloud SDK
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
sudo echo ${GCP_SERVICE_ACCOUNT} | base64 --decode -i > ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud config set project ${PROJECT_ID}
sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}

# create cluster
sudo chown -R circleci:circleci /home/circleci/.*
if [[ $(gcloud container clusters list |grep ${CLUSTER_NAME} |wc -l) == 0 ]]; then
        sudo /opt/google-cloud-sdk/bin/gcloud container clusters create ${CLUSTER_NAME} --zone ${CLOUDSDK_COMPUTE_ZONE} --num-nodes 2 --machine-type n1-standard-1
fi
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster ${CLUSTER_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}

# Push Registry
docker tag q3a-server:latest asia.gcr.io/${PROJECT_ID}/${REGISTRY_NAME}:${CIRCLE_SHA1}
sudo /opt/google-cloud-sdk/bin/gcloud docker -- push asia.gcr.io/${PROJECT_ID}/${REGISTRY_NAME}:${CIRCLE_SHA1}
sudo chown -R circleci:circleci /home/circleci/.kube
sudo chown -R circleci:circleci /home/circleci/.config
sudo chown -R circleci:circleci /home/circleci/.*

for f in k8s/*.yml
do
    envsubst < $f > "generated-$(basename $f)"
done
kubectl apply -f generated-deployment.yml
kubectl apply -f generated-service.yml

for attempt in {1..30}; do
#	kubectl get rc
	kubectl get nodes
	kubectl get pods
	kubectl get deployments
	kubectl get services
	sleep 3
	echo '================================================'
done
