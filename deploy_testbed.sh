#!/usr/bin/sh

cd deployment/
terraform init
terraform apply -auto-approve
cd -
