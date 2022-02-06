#!/usr/bin/env bash

exec_cmd(){
    c="$@"
    echo $c 
    eval $c 
}

# Удалить всё после создания Тераформом
terraform(){
    commands=()
    yc compute instances list --format json | jq -r .[].name | while read node; do 
        exec_cmd "yc compute instances delete --name $node"
    done
    exec_cmd "yc vpc subnet delete --name subnet"
    exec_cmd "yc vpc net delete --name net"
}

# Удалить имейдж, созданный Пакером
packer(){
    exec_cmd "yc compute images delete --name centos-7-base"
}

if [[ "$1" == "" ]]; then 
    terraform
elif [[ "$1" == "packer" ]]; then
    packer
elif [[ "$1" == "terraform" ]]; then 
    terraform
fi