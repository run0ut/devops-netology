#!/usr/bin/env bash

set -x
# set -euo pipefail

echo "Hi, Netology 11.4! Let's make some devops stuff!"

is_role_installed=$(ansible-galaxy collection list --format yaml | grep -c -w netology86.yandex_cloud_elk)
if [[ "$is_role_installed" == "0" ]]; then
    ansible-galaxy install -r requirements.yml
fi

ansible-playbook -i yc_inventory.yml playbook.yml
# ansible-playbook -i yc_inventory.yml playbook.yml --start-at-task "Download redis.rpm file"