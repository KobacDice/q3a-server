#!/bin/bash

# Exit on any error
set -e

PROJECT_NAME="work"
CLUSTER_NAME="q3a-server-cluster"
CLOUDSDK_COMPUTE_ZONE="asia-northeast1-a"
DEBIAN_FRONTEND="noninteractive"

# Setup Google Cloud SDK
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
sudo echo ${ACCT_AUTH} | base64 --decode -i > ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud config set project ${PROJECT_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster ${CLUSTER_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials ${CLUSTER_NAME}

# Push Registry
sudo /opt/google-cloud-sdk/bin/gcloud docker -- push asia.gcr.io/q3a-server-registry
