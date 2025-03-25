# BatCAT Testbed

Testbed for the BatCAT data space.

Current scope: Minimal LinkAhead deployment using Minikube.

## Running the Testbed

### Requirements

* Basic understanding of Kubernetes, Docker, Terraform, SSH.
* Docker installed
* Minikube installed
* Terraform installed
* SSH installed
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
5. Forward the local port 8080 to the ingress controller:
    `ssh -fN -i $(minikube ssh-key) docker@$(minikube ip) -L 8080:localhost:80`

> Step 0 to 5 are available by just calling `start_k8_cluster.sh`.

### Deploy the Testbed

Now, deploy the testbed, type 'yes' when promted (use `-auto-approve` to suppress the prompt):

```
cd deployment
terraform init
terraform apply [-auto-approve]
```

> You can call `deploy_testbed.sh` instead.

> You need to have the alias for kubectl available (see above), otherwise terraform will not be able to
> connect to you minikube cluster.


Once Terraform has completed the deployment, type `kubectl get pods` and verify the output:

```shell
❯ kubectl get pods -A
```

### Port-forwarding for Localhost

Before you can access either of the services locally, you need set up port-forwarding:

#### LinkAhead

* `LA_NODE_PORT="$(kubectl get -n batcat service linkahead-service -o go-template='{{range .spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')"`
* `ssh -fN -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i $(minikube ssh-key) docker@$(minikube ip) -L 40002:localhost:${LA_NODE_PORT}`

> You can call `port_forwarding.la.sh` instead

#### ElabFTW

* `ELAB_NODE_PORT="$(kubectl get -n batcat service elabftw-service  -o go-template='{{range .spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')"`
* `ssh -fN -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i $(minikube ssh-key) docker@$(minikube ip) -L 40002:localhost:${ELAB_NODE_PORT}`

> You can call `port_forwarding.elab.sh` instead

### Test LinkAhead

* Browse to `http://localhost:40001/`
* Note: this is plain http, not https!

### Test ElabFTW

* Browse to `https://localhost:40002/`
* Note: this is https, not plain http!

### Load a Custom LinkAhead Image

* Build the Docker image and tag it, e.g. `linkahead:build-1`. (The current default is
  `indiscale/linkahead:dev`.)
* Load the image into the minikube cluster:
    `minikube image load linkahead:build-1`
* Run `terraform apply -var linkahead-image="linkahead:build-1"`

### Stop k8s cluster

To stop everything:

```sh
minikube delete --all
```

## License

AGPL 3.0 or later

* Copyright (C) 2025 IndiScale GmbH <info@indiscale.com>
* Copyright (C) 2025 Timm Fitschen <t.fitschen@indiscale.com>
* Copyright (C) 2025 Henrik tom Wörden
* Copyright (C) 2025 Daniel Hornung

