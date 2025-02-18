#!/usr/bin/sh

# Useful aliases.  These are only available from the calling shell if this file was sourced and not
# called.  ("source start_k8_cluster.sh" instead of "./start_k8_cluster.sh")
unalias minikube
alias minikube='minikube -p batcat'
alias kubectl='minikube kubectl --'

# Start minikube
minikube start

# Wait for the ingress controller to become available:
minikube addons enable ingress
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Forward the local port 80 to the ingress controller
sudo ssh -fN -i $(minikube ssh-key) docker@$(minikube ip) -L 80:localhost:80
