#!/usr/bin/env bash

indexes="ind-1 	0 	1
ind-2 	1 	2
ind-3 	2 	4"

exec_cmd(){
    c="$@"
    echo $c 
    eval $c 
    echo 
}

create(){
    while read name repl shards; do
        exec_cmd "curl -ss -XPUT http://localhost:9200/${name} -H 'Content-Type: application/json' -d '{\"settings\":{\"index\":{\"number_of_replicas\":${repl},\"number_of_shards\":${shards}}}}'"
    done << EnfOfList
$indexes
EnfOfList
}

status(){
    exec_cmd "curl http://172.17.0.2:9200/_cat/indices?v=true"
    exec_cmd "curl -ss http://172.17.0.2:9200/_cluster/health?pretty"
}

delete(){
    while read name repl shards; do
        exec_cmd "curl -ss -XDELETE http://localhost:9200/${name}"
    done << EnfOfList
$indexes
EnfOfList
}

case ${1:-not_args} in
    "not_args") status;;
    *) $1;;
esac