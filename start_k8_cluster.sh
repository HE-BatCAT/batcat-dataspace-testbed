#!/usr/bin/sh

# check docker
docker --version
docker info

# check minikub
minikube version

# check ssh
ssh -V

. ./.common.sh

# Start minikube
minikube start
