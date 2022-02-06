# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

<details><summary>.</summary>

> В этом задании вы потренируетесь в:
> - установке elasticsearch
> - первоначальном конфигурировании elastcisearch
> - запуске elasticsearch в docker
> 
> Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
> [документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):
> 
> - составьте Dockerfile-манифест для elasticsearch
> - соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
> - запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины
> 
> Требования к `elasticsearch.yml`:
> - данные `path` должны сохраняться в `/var/lib`
> - имя ноды должно быть `netology_test`
> 
> В ответе приведите:
> - текст Dockerfile манифеста
> - ссылку на образ в репозитории dockerhub
> - ответ `elasticsearch` на запрос пути `/` в json виде
> 
> Подсказки:
> - возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
> - при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
> - при некоторых проблемах вам поможет docker директива ulimit
> - elasticsearch в логах обычно описывает проблему и пути ее решения
> 
> Далее мы будем работать с данным экземпляром elasticsearch.

</details>

### Текст Dockerfile манифеста

```Dockerfile
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.16.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.16.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.16.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.16.0 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum -y remove wget && \
    yum clean all
COPY --chown=elasticsearch:elasticsearch config/* /var/lib/elasticsearch/config/

USER 1000

ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}

CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]
```

### Ссылку на образ в репозитории dockerhub

https://hub.docker.com/r/runout/elastic_netology 

Чтобы запустить, нужно обязательно изменить параметр ядра `vm.max_map_count`, иначе упадёт с ошибкой:
```bash
sudo sysctl -w vm.max_map_count=262144
docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 runout/elastic_netology
```

### Ответ `elasticsearch` на запрос пути `/` в json виде

```json
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "mHHYRKPZT1SfPj-umyXIEA",
  "version" : {
    "number" : "7.16.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "6fc81662312141fe7691d7c1c91b8658ac17aa0d",
    "build_date" : "2021-12-02T15:46:35.697268109Z",
    "build_snapshot" : false,
    "lucene_version" : "8.10.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

<details><summary>.</summary>

> В этом задании вы научитесь:
> - создавать и удалять индексы
> - изучать состояние кластера
> - обосновывать причину деградации доступности данных
> 
> Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
> и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:
> 
> | Имя   | Количество реплик | Количество шард |
> | ----- | ----------------- | --------------- |
> | ind-1 | 0                 | 1               |
> | ind-2 | 1                 | 2               |
> | ind-3 | 2                 | 4               |
> 
> Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
> 
> Получите состояние кластера `elasticsearch`, используя API.
> 
> Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
> 
> Удалите все индексы.
> 
> **Важно**
> 
> При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
> иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

</details>

### Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```bash
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases mbpyFJ9sQHOV-nlI-oNIBg   1   0         42            0     41.1mb         41.1mb
green  open   ind-1            FSnFzgT6RVmExljZQeT-tA   1   0          0            0       226b           226b
yellow open   ind-3            4bJOszxTSayO-2BnfhaJ9A   4   2          0            0       226b           226b
yellow open   ind-2            5gq69worTjeYcZp_dZiLnA   2   1          0            0       226b           226b
```

### Получите состояние кластера `elasticsearch`, используя API.

```json
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```

### Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

У них должны быть реплики, но в кластере всего одна нода, поэтому размещать их негде. 
В таком случае кластер помечает их желтыми (из [доки по кластерам](https://www.elastic.co/guide/en/elasticsearch/reference/7.16/cluster-health.html#cluster-health-api-desc)).

## Задача 3

<details><summary>.</summary>

> В данном задании вы научитесь:
> - создавать бэкапы данных
> - восстанавливать индексы из бэкапов
> 
> Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
> 
> Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
> данную директорию как `snapshot repository` c именем `netology_backup`.
> 
> **Приведите в ответе** запрос API и результат вызова API для создания репозитория.
> 
> Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
> 
> [Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
> состояния кластера `elasticsearch`.
> 
> **Приведите в ответе** список файлов в директории со `snapshot`ами.
> 
> Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
> 
> [Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
> кластера `elasticsearch` из `snapshot`, созданного ранее. 
> 
> **Приведите в ответе** запрос к API восстановления и итоговый список индексов.
> 
> Подсказки:
> - возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

</details>

### **Приведите в ответе** запрос API и результат вызова API для создания репозитория.

`Запрос`
```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots",
    "compress": true
  }
}'
```
`Ответ`
```json
{
  "acknowledged" : true
}
```
### Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```tsv
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases xCjT_XLWT96qt1-Kp4xXgQ   1   0         42            0     41.1mb         41.1mb
green  open   test             2ocwHrSiQtqAIvuX04yt7g   1   0          0            0       226b           226b
```

### **Приведите в ответе** список файлов в директории со `snapshot`ами.

```bash
$ docker exec elastic3 ls -l /var/lib/elasticsearch/snapshots/
total 28
-rw-r--r-- 1 elasticsearch elasticsearch 1434 Dec 12 12:21 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Dec 12 12:21 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch 4096 Dec 12 12:21 indices
-rw-r--r-- 1 elasticsearch elasticsearch 9737 Dec 12 12:21 meta-fzn6GSxgSX-JC9wHwIWhNA.dat
-rw-r--r-- 1 elasticsearch elasticsearch  458 Dec 12 12:21 snap-fzn6GSxgSX-JC9wHwIWhNA.dat
```

### Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```tsv
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases xCjT_XLWT96qt1-Kp4xXgQ   1   0         42            0     41.1mb         41.1mb
green  open   test-2           2NVi48R_QqW73lxawMykRA   1   0          0            0       226b           226b
```

### **Приведите в ответе** запрос к API восстановления и итоговый список индексов.

`запрос к API восстановления`, ещё потребовалось сделать запросы из [документации](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) на выключение/включение фич и удалени индексов, их копировал 1 в 1
```bash
curl -X POST "localhost:9200/_snapshot/netology_backup/my_snapshot_2021.12.12/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "include_global_state": false
}
'
```
`итоговый список индексов`
```tsv
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases 4zMXz3RMR-SY48JnHNJWlQ   1   0         42            0     41.1mb         41.1mb
green  open   test             bf7x24BMS-iplwoPN0PzWQ   1   0          0            0       226b           226b
```