devops-netology
===============

# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."

<details><summary>.</summary>

> Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 

</details>

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

<details><summary>.</summary>

> Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 
> 
> AWS предоставляет достаточно много бесплатных ресурсов в первых год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
> 1. Создайте аккаут aws.
> 1. Установите c aws-cli https://aws.amazon.com/cli/.
> 1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
> 1. Создайте IAM политику для терраформа c правами
>     * AmazonEC2FullAccess
>     * AmazonS3FullAccess
>     * AmazonDynamoDBFullAccess
>     * AmazonRDSFullAccess
>     * CloudWatchFullAccess
>     * IAMFullAccess
> 1. Добавьте переменные окружения 
>     ```
>     export AWS_ACCESS_KEY_ID=(your access key id)
>     export AWS_SECRET_ACCESS_KEY=(your secret access key)
>     ```
> 1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 
> 
> В виде результата задания приложите вывод команды `aws configure list`.

</details>

### В виде результата задания приложите вывод команды aws configure list.
```log
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************IA6V shared-credentials-file
secret_key     ****************37LS shared-credentials-file
    region               eu-north-1      config-file    ~/.aws/config
```

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

<details><summary>.</summary>

> 1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
> 3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки базового терраформ конфига.
> 4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

</details>

```bash
$ yc config list
token: суперсекретныйтокен
cloud-id: b1g19qmh5o80gm94ufu8
folder-id: b1g01oeuesd31te4bm64
compute-default-zone: ru-central1-a
```

## Задача 2. Созданием aws ec2 или yandex_compute_instance через терраформ. 

<details><summary>.</summary>

> 1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
> 2. Зарегистрируйте провайдер 
>    1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион внутри блока `provider`.
>    2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали их в виде переменных окружения. 
> 4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
> 5. В файле `main.tf` создайте рессурс 
>    1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
>    Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке `Example Usage`, но желательно, указать большее количество параметров.
>    2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
> 6. Также в случае использования aws:
>    1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
>    2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
>        * AWS account ID,
>        * AWS user ID,
>        * AWS регион, который используется в данный момент, 
>        * Приватный IP ec2 инстансы,
>        * Идентификатор подсети в которой создан инстанс.  
> 7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 
> 
> 
> В качестве результата задания предоставьте:
> 1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
> 1. Ссылку на репозиторий с исходной конфигурацией терраформа. 

</details> 

### Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 

Аналога `aws_caller_identity` у провайдера Yandex нет, поэтому только адрес, ID подсети и зона.
```log
...
Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + IP_compute_instance = (known after apply)
  + Yandex_vpc_subnet   = (known after apply)
  + Yandex_zone         = (known after apply)
yandex_vpc_network.net: Creating...
yandex_vpc_network.net: Creation complete after 1s [id=enp1eus8gd123vocs73d]
yandex_vpc_subnet.subnet: Creating...
yandex_vpc_subnet.subnet: Creation complete after 0s [id=e9bu96olg7sp6f659v70]
yandex_compute_instance.vm: Creating...
yandex_compute_instance.vm: Still creating... [10s elapsed]
yandex_compute_instance.vm: Still creating... [20s elapsed]
yandex_compute_instance.vm: Creation complete after 21s [id=fhmf7gbadds114fv7usi]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

IP_compute_instance = "10.2.0.16"
Yandex_vpc_subnet = "e9bu96olg7sp6f659v70"
Yandex_zone = "ru-central1-a"
```

### При помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?

Packer

### Ссылку на репозиторий с исходной конфигурацией терраформа. 

https://github.com/run0ut/devops-netology/tree/main/misc/72
