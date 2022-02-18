devops-netology
===============

# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

<details><summary>.</summary>

> Бывает, что 
> * общедоступная документация по терраформ ресурсам не всегда достоверна,
> * в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
> * понадобиться использовать провайдер без официальной документации,
> * может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

</details>  

## Задача 1. 

<details><summary>.</summary>

> Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
> [https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
> Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  
> 
> 1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на гитхабе.   
> 1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
>     * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
>     * Какая максимальная длина имени? 
>     * Какому регулярному выражению должно подчиняться имя? 

</details>  

### Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на гитхабе. 

Андрей Борю посоветовал на вебинаре смотреть в старой версии провайдера. Изучал версию **2.70.0**:

  * `resource`

    https://github.com/hashicorp/terraform-provider-aws/blob/ac5cfe4e10449b7aaaba1b3690065d4fedd5a421/aws/provider.go#L366

  * `data_source`
    
    https://github.com/hashicorp/terraform-provider-aws/blob/ac5cfe4e10449b7aaaba1b3690065d4fedd5a421/aws/provider.go#L170

Это помогло найти тот же код в актуальной версии **3.74.0**:

  * `resource`
    
    https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/provider/provider.go#L754

  * `data_source`
    
    https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/provider/provider.go#L346

### С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.

`name` конфликтует с `name_prefix`, это указано в [строке №87](https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/service/sqs/queue.go#L87)

### Какая максимальная длина имени? 

Она описана в [этом блоке](https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/service/sqs/queue.go#L424) и не может превышать [80 символов](https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/service/sqs/queue.go#L427). Если это FIFO очередь, [то 75 символов](https://github.com/hashicorp/terraform-provider-aws/blob/8ed579596823be7604461c75ad564c83bf3b6c69/internal/service/sqs/queue.go#L425), плюс "расширение" `.fifo` в конце, это 5 символов. В сумме тоже 80.

### Какому регулярному выражению должно подчиняться имя? 

* `^[a-zA-Z0-9_-]{1,80}$` - может содержать символы латинского алфавита, цифры, нижнее подчёркивание и дефис, длиной от 1 до 80 символов. Начинаться может с любого из этих символов.
* `^[a-zA-Z0-9_-]{1,75}\.fifo$` - то же самое для FIFO очередей, только длина от 1 до 75 символов и должно заканчиваться на `.fifo`

## Задача 2. (Не обязательно) 

<details><summary>.</summary>

> В рамках вебинара и презентации мы разобрали как создать свой собственный провайдер на примере кофемашины. 
> Также вот официальная документация о создании провайдера: 
> [https://learn.hashicorp.com/collections/terraform/providers](https://learn.hashicorp.com/collections/terraform/providers).
> 
> 1. Проделайте все шаги создания провайдера.
> 2. В виде результата приложение ссылку на исходный код.
> 3. Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции.   

</details>  

### В виде результата приложение ссылку на исходный код.

https://github.com/run0ut/terraform-provider-hashicups/tree/boilerplate

### Попробуйте скомпилировать провайдер, если получится то приложите снимок экрана с командой и результатом компиляции. 

![скриншот сборки провайдера из исходников](./media/virt-76-terraform-build-provider.png)