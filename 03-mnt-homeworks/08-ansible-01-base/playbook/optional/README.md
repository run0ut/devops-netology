## Необязательная часть

<details><summary>.</summary>

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
   ```bash
   ansible-vault decrypt group_vars/deb/examp.yml --vault-password-file vault_password.txt
   ansible-vault decrypt group_vars/el/examp.yml --vault-password-file vault_password.txt
   ```
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
   ```
   $ ansible-vault encrypt_string --vault-password-file vault_password.txt PaSSw0rd
   !vault |
             $ANSIBLE_VAULT;1.1;AES256
             61353965636234343863313138323234303731343464393765306363636439353964353665333764
             6165623638393865626337336532373862653235663235380a386463633362343931643137363038
             32663361373461616266303436313363633961306134363362383133393136313164616165613236
             6234303365356230370a656230333466363437306261306437373234326266663836373434313030
             6432
   Encryption successful
   ```
   ```bash
   $ cat group_vars/all/examp.yml
   ---
     some_fact: !vault |
             $ANSIBLE_VAULT;1.1;AES256
             61353965636234343863313138323234303731343464393765306363636439353964353665333764
             6165623638393865626337336532373862653235663235380a386463633362343931643137363038
             32663361373461616266303436313363633961306134363362383133393136313164616165613236
             6234303365356230370a656230333466363437306261306437373234326266663836373434313030
             6432
   ```          
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
   ```bash
   $ ansible-playbook site.yml -i inventory/prod.yml --vault-pass-file vault_password.txt
   
   PLAY [Print os facts] ************************************************************************************************
   
   TASK [Gathering Facts] ***********************************************************************************************
   ok: [localhost]
   ok: [ubuntu]
   ok: [centos7]
   
   TASK [Print OS] ******************************************************************************************************
   ok: [localhost] => {
       "msg": "Debian"
   }
   ok: [centos7] => {
       "msg": "CentOS"
   }
   ok: [ubuntu] => {
       "msg": "Ubuntu"
   }
   
   TASK [Print fact] ****************************************************************************************************
   ok: [localhost] => {
       "msg": "PaSSw0rd"
   }
   ok: [centos7] => {
       "msg": "el default fact"
   }
   ok: [ubuntu] => {
       "msg": "deb default fact"
   }
   
   PLAY RECAP ***********************************************************************************************************
   centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

</details>

4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
   ```yaml
   $ cat inventory/prod.yml
   ---
   ...
     fed:
       hosts:
         fedora:
           ansible_connection: docker
   ...
   ```
   ```yaml
   $ cat site.yml
   ---
     - name: Print os facts
       hosts: all
       tasks:
   ...
         - name: Print custom var
           debug:
             msg: "{{ custom_var }}"
           when:
             - ansible_distribution == "Fedora"
   ```
   ```yaml
   $ cat group_vars/fed/examp.yml
   ---
     custom_var: "Hi, Netology!"
   ```
   ```bash
   $ ansible-playbook site.yml -i inventory/prod.yml --vault-password-file vault_password.txt
   
   PLAY [Print os facts] ***********************************************************************************************
   
   TASK [Gathering Facts] **********************************************************************************************
   ok: [localhost]
   ok: [fedora]
   ok: [centos7]
   ok: [ubuntu]
   
   TASK [Print OS] *****************************************************************************************************
   ok: [localhost] => {
       "msg": "Debian"
   }
   ok: [centos7] => {
       "msg": "CentOS"
   }
   ok: [ubuntu] => {
       "msg": "Ubuntu"
   }
   ok: [fedora] => {
       "msg": "Fedora"
   }
   
   TASK [Print fact] ***************************************************************************************************
   ok: [localhost] => {
       "msg": "PaSSw0rd"
   }
   ok: [centos7] => {
       "msg": "el default fact"
   }
   ok: [ubuntu] => {
       "msg": "deb default fact"
   }
   ok: [fedora] => {
       "msg": "PaSSw0rd"
   }
   
   TASK [Print custom var] *********************************************************************************************
   skipping: [centos7]
   skipping: [ubuntu]
   skipping: [localhost]
   ok: [fedora] => {
       "msg": "Hi, Netology!"
   }
   
   PLAY RECAP **********************************************************************************************************
   centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
   fedora                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
   ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
   ```
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
   ```bash
   #!/usr/local/env bash
   docker-compose up -d
   ansible-playbook site.yml -i inventory/prod.yml --vault-password-file vault_password.txt
   docker-compose down
   ```
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

   [commit](https://github.com/run0ut/netology-81/commit/9a61e0a3c6ed0af443dba22d6df00b69b0452c34)