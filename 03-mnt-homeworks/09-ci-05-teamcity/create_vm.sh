#!/usr/bin/env bash

set -eu

create_network(){
    yc vpc network create \
        --name net \
        --labels my-label=netology \
        --description "netology homework 54 net"
    yc vpc subnet create \
        --name subnet \
        --zone ru-central1-a \
        --range 10.1.2.0/24 \
        --network-name net \
        --description "netology homework 54 subnet"
}

create_teamcity(){

    # --name — имя ВМ.
    # --zone — зона доступности.
    # --ssh-key — содержимое файла открытого ключа.
    # --service-account-name — имя сервисного аккаунта.
    # --public-ip — выделение публичного IP-адреса для ВМ.
    # --container-name — имя Docker-контейнера.
    # --container-image — имя Docker-образа для запуска Docker-контейнера.
    # --container-command — команда, которая будет выполнена при запуске Docker-контейнера.
    # --container-arg — параметры для команды, указанной с помощью --container-command.
    # --container-env — переменные окружения, доступные внутри Docker-контейнера.
        # --container-env=KEY1=VAL1,KEY2=VAL2 \
    # --container-privileged — запуск Docker-контейнера в привилегированном режиме.

    yc compute instance create-with-container \
        --name teamcity \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 4 \
        --platform "standard-v1" \
        --core-fraction 100 \
        --memory 4GB \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --container-name=teamcity \
        --container-image=jetbrains/teamcity-server
}

create_agent(){

    server_ip=$(
        yc compute instances list --format=json | \
        jq -r '.[] |  select(.name=="teamcity") | .network_interfaces[0].primary_v4_address.address'
    )
    server_url=http://${server_ip}:8111

    yc compute instance create-with-container \
        --name teamcity-agent \
        --zone ru-central1-a \
        --ssh-key ~/.ssh/id_rsa.pub \
        --cores 2 \
        --platform "standard-v1" \
        --core-fraction 100 \
        --memory 4GB \
        --network-interface subnet-name=subnet,nat-ip-version=ipv4 \
        --container-name=teamcity \
        --container-image=jetbrains/teamcity-agent \
        --container-env=SERVER_URL=${server_url}
}

delete_teamcity(){
    yc compute instance delete teamcity
}

delete_agent(){
    yc compute instance delete teamcity-agent
}

delete_network(){
    yc vpc subnet delete net
    yc vpc network delete net
}

declare ACTION=$1

case $ACTION in
    "create_all")
        create_network
        create_teamcity
        create_agent
        ;;
    "delete_all")
        create_agent
        create_teamcity
        create_network
        ;;
    *)
        $ACTION
        ;;
esac