# BatCAT Testbed

Testbed for the BatCAT data space.

Current scope: Minimal LinkAhead deployment using Minikube.

## Running the Testbed

### Requirements

* Basic understanding of Kubernetes, Docker, Terraform.
* Docker installed
* Minikube installed
* Terraform installed
* a POSIX-compliant shell

All commands are executed from the repository's root directory unless stated otherwise.

> Since this is not a production deployment, all applications are deployed _in the same cluster_ and in the
> same namespace, plainly for the sake of simplicity.

### Create the K8S cluster

Now, we configure and start the Kubernetes cluster using Minikube:

0. `alias minikube='minikube -p batcat'`
1. `alias kubectl='minikube kubectl --'`
2. `minikube start`
3. `minikube addons enable ingress`
4. Wait for the ingress controller to become available:
    ```
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
    ```
5. Forward the local port 80 to the ingress controller:
    `sudo ssh -fN -i $(minikube ssh-key) docker@$(minikube ip) -L 80:localhost:80`

> Step 0 to 5 are available by just calling `start_k8_cluster.sh`.

### Deploy the Testbed

Now, deploy the testbed, type 'yes' when promted:

```
cd deployment
terraform init
terraform apply
```

> You can call `deploy_testbed.sh` instead.


Once Terraform has completed the deployment, type `kubectl get pods` and verify the output:

```shell
❯ kubectl get pods -A
```

### Test LinkAhead

* Browse to `http://localhost/linkahead`

### Load a Custom LinkAhead Image

* Build the Docker image and tag it, e.g. `linkahead:build-1`
* Load the image into the minikube cluster:
    `minikube image load linkahead:build-1`
* Run `terraform apply -var linkahead-image="linkahead:build-1"`

## License

TODO
