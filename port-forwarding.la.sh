#!/bin/sh

. ./.common.sh

LA_NODE_PORT="$(kubectl get -n batcat service linkahead-service  -o go-template='{{range .spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')"
ssh -fN -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i $(minikube ssh-key) docker@$(minikube ip) -L 40001:localhost:${LA_NODE_PORT}
