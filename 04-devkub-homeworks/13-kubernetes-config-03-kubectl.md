# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента

> Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
> * сделайте запросы к бекенду;
> * сделайте запросы к фронту;
> * подключитесь к базе данных.

За основу взял стек `prod` из [13.2](./13-kubernetes-config-02-mounts.md), для запросов добавил `multitool`.

![Стек](./media/13-3-%D0%A1%D0%BA%D1%80%D0%B8%D0%BD%D1%88%D0%BE%D1%82_kubectl_get.png)

### Сделайте запросы к бекенду

* port-forward
    ![back port forward](./media/13-3-back_port_forward.png)
* exec из мультитула в бек
    ![multitool to back](./media/13-3-multitool_to_back.png)
### Сделайте запросы к фронту

* port-forward
    ![front port forward](./media/13-3-front_port_forward.png)
* exec от бека во фронт
    ![back to front](./media/13-3-back_to_front.png)

### Подключитесь к базе данных

Подключение к базе из мультитула.

![Запросы к БД, скриншот терминала](./media/13-3-psql.png)

## Задание 2: ручное масштабирование

> При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

До скейла, оба деплоймента были на первой ноде.

По два пода фронта и бека оказалось на первой нулевой и по одному на первой.

Уменьшил количество копий командой `kubectl patch`. По итогу все поды неймспейса оказались на нулевой ноде.

![Scale](./media/13-3-scale.png)