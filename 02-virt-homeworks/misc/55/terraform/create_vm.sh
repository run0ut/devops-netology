#!/usr/bin/env bash 

rm -f terraform.tfstate.backup
rm -f terraform.tfstate
../erase.sh terraform

export TF_VAR_yandex_cloud_id=$(yc config get cloud-id) 
export TF_VAR_yandex_folder_id=$(yc config get folder-id) 
export TF_VAR_centos_7_base=$(yc compute images get --name centos-7-base --format json | jq -r .id) 

terraform apply -auto-approve

unset TF_VAR_yandex_cloud_id \
      TF_VAR_yandex_folder_id \
      TF_VAR_centos_7_base