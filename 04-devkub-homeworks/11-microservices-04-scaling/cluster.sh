#!/usr/bin/env bash

declare NODES=()
declare MASTER_PORT=6379
declare SLAVE_PORT=6380

install_collection(){
    is_role_installed=$(ansible-galaxy collection list --format yaml | grep -c -w netology86.yandex_cloud_elk)
    if [[ "$is_role_installed" == "0" ]]; then
        ansible-galaxy install -r ansible/requirements.yml
    fi
}

playbook(){
    ansible-playbook -i ansible/yc_inventory.yml ansible/playbook.yml
}

destroy_nodes(){
    ansible-playbook -i ansible/yc_inventory.yml ansible/destroy.yml
}

nodes(){
    NODES=($(
        ansible -i ansible/yc_inventory.yml -m debug -a "var=hostvars[inventory_hostname].ansible_host" all | \
        grep ansible_host | \
        sed 's/.*\.ansible_host//g; s/[: "]*//g; s/$//g'
    ))
}

show_docker(){
    for node in ${NODES[@]}; do
        echo ssh yc-user@${node} sudo docker ps
        ssh yc-user@${node} sudo docker ps
        echo
    done
}

create_cluster(){
    exec_line="redis-cli --cluster create"
    for node in ${NODES[*]}; do 
        exec_line="$exec_line ${node}:${MASTER_PORT}"
    done
    exec_line="$exec_line --cluster-yes"
    echo $exec_line
    eval $exec_line
}

meet_nodes(){
    for i in ${!NODES[@]}; do
        for y in $(seq 1 $((${#NODES[@]}-1))); do
            echo redis-cli -h ${NODES[$i]} -p ${MASTER_PORT} CLUSTER MEET ${NODES[$(($i-$y))]} ${MASTER_PORT}
            redis-cli -h ${NODES[$i]} -p ${MASTER_PORT} CLUSTER MEET ${NODES[$(($i-$y))]} ${MASTER_PORT}
        done
    done
}

show_nodes(){
    # Это нужно чтобы правильно работал греп
    # Т.к. ноды а) в яндексе с белым адресом выданным методом статик ната б) в докере
    # В общем, нода не знает свой внешний айпишник и в выводе себя всегда показывает с серым
    # Поэтому спрашиваем соседнюю ноду, чтобы можно было грепнуть себя
    number=${1:-1}
    node_id=$(($number-1))
    #
    redis-cli -h ${NODES[$node_id]} -p ${MASTER_PORT} cluster NODES
}

remove_cluster(){
    for node in ${NODES[@]}; do 
        echo redis-cli -h ${node} -p ${MASTER_PORT} cluster reset; 
        redis-cli -h ${node} -p ${MASTER_PORT} cluster reset; 
    done
}

configure_slaves(){
    echo
    for i in ${!NODES[@]}; do
        master_id=$(show_nodes $i | grep ${NODES[$i]}:${MASTER_PORT} | awk '{print $1}')
        echo redis-cli --cluster \
            add-node \
                ${NODES[$(($i-1))]}:${SLAVE_PORT} \
                ${NODES[$i]}:${MASTER_PORT} \
            --cluster-slave \
            --cluster-master-id $master_id
        redis-cli --cluster \
            add-node \
                ${NODES[$(($i-1))]}:${SLAVE_PORT} \
                ${NODES[$i]}:${MASTER_PORT} \
            --cluster-slave \
            --cluster-master-id $master_id
        echo
    done
}

echo "Hi, Netology 11.4! Let's make some devops stuff!"

case $1 in
    "create_cluster"|"meet_nodes"|"show_nodes"|"remove_cluster"|"configure_slaves"|"show_docker")
        echo "gather nodes info"
        nodes
        $1
        ;;
    "playbook"|"destroy_nodes")
        echo "check collection is insatlled"
        install_collection
        $1
        ;;
    "provision")
        echo "deploy complete stack"
        install_collection
        playbook
        nodes
        create_cluster
        configure_slaves
        ;;
    *)
        $1
        ;;
esac
echo 