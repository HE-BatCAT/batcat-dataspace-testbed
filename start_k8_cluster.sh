#!/usr/bin/sh

# Useful aliases
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
