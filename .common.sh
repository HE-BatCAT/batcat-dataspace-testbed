set -Eeuo pipefail

# Useful aliases.  These are only available from the calling shell if this file was sourced and not
# called.  ("source start_k8_cluster.sh" instead of "./start_k8_cluster.sh")
unalias minikube &> /dev/null || true
alias minikube='minikube -p batcat'
alias kubectl='minikube kubectl --'

