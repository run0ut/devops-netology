# Что делает скрипт

Скрипт создаст три виртуальные машины в Яндексе.Облаке и развернёт на каждой по два инстанса `redis`.

Инстансы свяжет в кластер по схеме, изображенной на [картинке](./media/scheme.png).

# Requirements

* ansible-core>=2.12
* ansible>=5.9
* Yandex CLI >= 0.91
* Redis CLI >= 6.0

# Как использовать

* Развернуть стек
    ```bash
    ./cluster.sh provision
    ```
* Посмотреть информацию по нодам в кластере
    ```bash
    ./cluster.sh show_nodes
    ```
* Показать запущенные контейнеры на нодах (`docker ps`)
    ```
    ./cluster.sh show_docker
    ```
* Удалить виртуальные машины
    ```bash
    ./cluster.sh destroy_nodes
    ```
