#!/usr/bin/env bash 

rm -f terraform.tfstate.backup
rm -f terraform.tfstate

../erase.sh terraform
export CENTOS_7_BASE=$(yc compute images get --name centos-7-base --format json | jq -r .id) 
terraform apply -auto-approve
unset CENTOS_7_BASE