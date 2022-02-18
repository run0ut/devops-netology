# netology-82

### Что делает playbook

Плейбук развернёт на хосте три приложения:
- jdk
- elasticsearch
- kibana

Дистрибутив JDK в `.tar.gz` архиве нужно предварительно [скачать](https://www.oracle.com/ru/java/technologies/javase/jdk11-archive-downloads.html) и положить в папку `files`.

Дистрибутивы Elasticsearch и Kibana будут скачаны при запуске плейбука.

### Какие у него есть параметры 

- IP хоста нужно задать в файле инвентаризации [prod.yml](inventory/prod.yml)
- Версия Java вероятно поменяется, нужно задать в [group_vars/all](group_vars/all/vars.yml)
- Подразумевается, что версии Elastic и Kibana одинаковые
- Все приложения будут установлены в `/opt` с правами `root`

### Какие у него есть теги

- java
- elastic
- kibana
