#!/bin/bash

# Exit on any error
set -e

PROJECT_ID="work-164802"
CLUSTER_NAME="q3a-server-cluster"
CLOUDSDK_COMPUTE_ZONE="asia-northeast1-a"
DEBIAN_FRONTEND="noninteractive"

# Setup Google Cloud SDK
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
sudo echo ${ACCT_AUTH} | base64 --decode -i > ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud config set project ${PROJECT_ID}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster ${CLUSTER_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}

# Push Registry
docker tag q3a-server:${CIRCLE_SHA1} asia.gcr.io/${PROJECT_ID}/q3a-server:${CIRCLE_SHA1}
sudo /opt/google-cloud-sdk/bin/gcloud docker -- push asia.gcr.io/${PROJECT_ID}/q3a-server:${CIRCLE_SHA1}
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube

kubectl get services
#kubectl set image deployment/q3a-server q3a-server=q3a-server:${CIRCLE_SHA1}
kubectl run q3a-server --image=asia.gcr.io/${PROJECT_ID}/q3a-server:${CIRCLE_SHA1} --expose=true --port=27960 --command -- "server"
kubectl expose deployment q3a-server --port=27960 --target-port=27960 --protocol=UDP --type="LoadBalancer"

kubectl get deployments
kubectl get pods
sleep 10
kubectl get services
kubectl get rs
kubectl get pods --show-labels
kubectl rollout status deployment/q3a-server

return 0