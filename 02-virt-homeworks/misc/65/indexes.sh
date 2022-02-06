#!/usr/bin/env bash

indexes="ind-1 	0 	1
ind-2 	1 	2
ind-3 	2 	4"

indexes31="test  	0 	1"
indexes32="test-2  	0 	1"

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

create31(){
    while read name repl shards; do
        exec_cmd "curl -ss -XPUT http://localhost:9200/${name} -H 'Content-Type: application/json' -d '{\"settings\":{\"index\":{\"number_of_replicas\":${repl},\"number_of_shards\":${shards}}}}'"
    done << EnfOfList
$indexes31
EnfOfList
}

create32(){
    while read name repl shards; do
        exec_cmd "curl -ss -XPUT http://localhost:9200/${name} -H 'Content-Type: application/json' -d '{\"settings\":{\"index\":{\"number_of_replicas\":${repl},\"number_of_shards\":${shards}}}}'"
    done << EnfOfList
$indexes32
EnfOfList
}

delete(){
    while read name repl shards; do
        exec_cmd "curl -ss -XDELETE http://localhost:9200/${name}"
    done << EnfOfList
$indexes
EnfOfList
}

delete31(){
    while read name repl shards; do
        exec_cmd "curl -ss -XDELETE http://localhost:9200/${name}"
    done << EnfOfList
$indexes31
EnfOfList
}

delete32(){
    while read name repl shards; do
        exec_cmd "curl -ss -XDELETE http://localhost:9200/${name}"
    done << EnfOfList
$indexes32
EnfOfList
}

backup_configure(){
    curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots",
    "compress": true
  }
}'
}

backup_create(){
    curl -X PUT "localhost:9200/_snapshot/netology_backup/%3Cmy_snapshot_%7Bnow%2Fd%7D%3E?pretty&wait_for_completion=true"
}

backup_restore(){
    # Остановить индексирование 
    curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"ingest.geoip.downloader.enabled": false}}'
    curl -X POST "localhost:9200/_ilm/stop?pretty"
    curl -X POST "localhost:9200/_ml/set_upgrade_mode?enabled=true&pretty"
    curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"xpack.monitoring.collection.enabled": false}}'
    curl -X POST "localhost:9200/_watcher/_stop?pretty"
    # Отключить безопасное удаление
    curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"action.destructive_requires_name": false}}'
    # Удалить все индексы
    curl -X DELETE "localhost:9200/_data_stream/*?expand_wildcards=all&pretty"
    curl -X DELETE "localhost:9200/*?expand_wildcards=all&pretty"
    # Получить имя последнего бекапа
    snapshot_name=$(curl -ss -X GET "localhost:9200/_snapshot/netology_backup/*?pretty&size=1&sort=name&order=desc" | jq -r .snapshots[0].snapshot)
    # Восстановить 
    curl -X POST "localhost:9200/_snapshot/netology_backup/${snapshot_name}/_restore?pretty" -H 'Content-Type: application/json' -d'{"indices": "*","include_global_state": false}'
    # Включить индексирование
    curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"ingest.geoip.downloader.enabled": true}}'
    curl -X POST "localhost:9200/_ilm/start?pretty"
    curl -X POST "localhost:9200/_ml/set_upgrade_mode?enabled=false&pretty"
    curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'{"persistent": {"xpack.monitoring.collection.enabled": true}}'
    curl -X POST "localhost:9200/_watcher/_start?pretty"
}

status(){
    exec_cmd "curl http://localhost:9200/_cat/indices?v=true"
    exec_cmd "curl -ss http://localhost:9200/_cluster/health?pretty"
    exec_cmd "curl -ss http://localhost:9200/_snapshot?pretty"
}

case ${1:-not_args} in
    "not_args") status;;
    *) $1;;
esac