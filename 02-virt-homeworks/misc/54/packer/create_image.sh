#!/usr/bin/env bash

create_net(){
    echo $(yc vpc network create \
        --name net \
        --labels my-label=netology \
        --description "netology homework 54 net" --format json | jq -r .id)
    
}
create_subnet(){
    echo $(yc vpc subnet create \
    --name subnet \
    --zone ru-central1-a \
    --range 10.1.2.0/24 \
    --network-name net \
    --description "netology homework 54 subnet" --format json | jq -r .id)
}

subnet_id=$(yc vpc subnet get --name subnet --format json 2>/dev/null | jq -r .id)
net_id=$(yc vpc net get --name net --format json 2>/dev/null | jq -r .id)

if [[ "$net_id" == '' ]]; then 
    net_id=$(create_net)
fi 
if [[ "$subnet_id" == '' ]]; then 
    subnet_id=$(create_subnet)
fi 

packer build -var "token=$(yc config get token)" -var "subnet_id=${subnet_id}" centos-7-base.json
