#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
from ast import mod
# from asyncore import file_dispatcher
# from importlib.resources import path
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    path:
        description: Path to file to create ot set content
        required: true
        type: str
    content:
        description: Content for the file.
        required: false
        type: str
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - netology-86.yandex_cloud_elk.my_own_module

author:
    - Sergey Shadurskiy (@run0ut)
'''

EXAMPLES = r'''
# Create a file
- name: Testing module with default content
  netology-86.yandex_cloud_elk.my_own_module:
    path: "~/file.txt

# change content of the  file and have changed true
- name: Testing module with user defined content
  netology-86.yandex_cloud_elk.my_own_module:
    path: "~/file.txt
    content: "My text"

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# The module has no returns
'''

from ansible.module_utils.basic import AnsibleModule
import os
import subprocess
import json

def check_if_file_exists(path):
    if os.path.exists(path):
        return True
    else:
        return False


def check_if_regular_file(path):
    if os.path.isfile(path):
        return True
    else:
        return False


def get_file_content(path):
    with open(path, 'r') as file:
        content = file.read()
    return content


def check_if_content_the_same(path, content):
    file_content = get_file_content(path)
    if file_content == content:
        return True
    else:
        return False


def create_and_fill_file_with_content(path, content):
    with open(path, 'w') as file:
        file.write(content)
    return True


def create_instance(args):

    # yc compute instance create --name elk-instance --create-boot-disk image-folder-id=standard-images,image-family=debian-9
    #     --name elk-instance \
    #     --hostname elk-intsance \
    #     --create-boot-disk image-family=centos-7
    #     --network-interface subnet-name=net-ru-central1-a,nat-ip-version=ipv4 \
    #     --zone ru-central1-a \
    #     --ssh-key ~/.ssh/id_rsa.pub \
    #     --cores 4 \
    #     --core-fraction 100 \
    #     --memory 4GB \
    #     --platform "standard-v1" \

    args['ssh_key'] = os.path.expanduser(args['ssh_key'])
    vars = [
        "yc", "compute", "instance", "create",
        "--name", args['name'],
        "--hostname", args['hostname'],
        "--network-interface", "subnet-name={network_interface},nat-ip-version=ipv4".format(**args),
        "--zone", args['zone'],
        "--ssh-key", args['ssh_key'],
        "--cores", args['cores'],
        "--core-fraction", args['core_fraction'],
        "--memory", "{memory}GB".format(**args),
        "--platform", "{platform}".format(**args),
        "--create-boot-disk","image-folder-id=standard-images,image-family={image_family},size={boot_disk_size}GB".format(**args)
    ]
    process = subprocess.Popen(vars, 
                        stdout=subprocess.PIPE,
                        universal_newlines=True)
    process.wait()
    # for stdout_line in iter(process.stdout.readline, ""):
    #     print(stdout_line)


def get_instance_info(args):

    # yc compute instance get --name netology86-instance --format=json
    
    vars = [
        "yc", "compute", "instance", "get", 
        "--name", args['name'], 
        "--format=json"
    ]
    process = subprocess.Popen(vars, 
                    stdout=subprocess.PIPE,
                    universal_newlines=True)
    process.wait()
    data, err = process.communicate()
    if process.returncode == 0:
        return data
    else:
        print("Error:", err)
    return "{}"


def main():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=False, default="netology86-instance"),
        hostname=dict(type='str', required=False, default="netology86-intsance"),
        network_interface=dict(type='str', required=True),
        zone=dict(type='str', required=False, default="ru-central1-a"),
        ssh_key=dict(type='str', required=False, default="~/.ssh/id_rsa.pub"),
        cores=dict(type='str', required=False, default="2"),
        core_fraction=dict(type='str', required=False, default="100"),
        memory=dict(type='str', required=False, default="4"),
        platform=dict(type='str', required=False, default="standard-v1" ),
        image_family=dict(type='str', required=False, default="centos-7" ),
        boot_disk_size=dict(type='str', required=False, default="20")
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    instance_info = json.loads(get_instance_info(module.params))

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        if not "network_interfaces" in instance_info:
            result['changed'] = True
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)

    # Assume file doesn't exist or has a different content
    # then theck if it's true
    if "network_interfaces" in instance_info:
        # print(instance_info['network_interfaces'][0]['primary_v4_address']['one_to_one_nat']['address'])
        pass
    else:
        create_instance(module.params)
        result['changed'] = True
    

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


if __name__ == '__main__':
    main()