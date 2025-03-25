#!/bin/sh

. ./.common.sh

ELAB_NODE_PORT="$(kubectl get -n batcat service elabftw-service  -o go-template='{{range .spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')"
ssh -fN -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i $(minikube ssh-key) docker@$(minikube ip) -L 40002:localhost:${ELAB_NODE_PORT}
