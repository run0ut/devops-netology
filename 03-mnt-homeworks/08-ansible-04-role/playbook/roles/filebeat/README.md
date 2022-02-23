Ansible-Role Filebeat for CentOS 7
=========

Role installs Filebeat on CentOS 7. 

Tested on CentOS 7.9.2009 (Core).

Requirements
------------

None.

Role Variables
--------------

Available variables are listed below, along with default values (see defaults/main.yml):

* The version of filebeat to install.
  ```yml
  filebeat_version: "7.14.0"
  ```
* The URL (including port) over which Filebeat will send data to Elasticsearch.
  ```yml
  filebeat_elasticsearch_url: "http://localhost:9200"
  ```
* The URL (including port) over which Filebeat will load dashboards to Kibana.
  ```yml
  filebeat_kibana_url:  "http://localhost:5601"
  ```

Dependencies
------------

None.

Example Playbook
----------------

The simpliest example:
```yaml
- name: Install Filebeat
  roles:
    - filebeat-role
```
Below is more complete example with variables.
```yaml
- name: Install Filebeat
  hosts: filebeat
  vars:
    - filebeat_elasticsearch_url: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200/"]
    - filebeat_kibana_url:  "http://{{ hostvars['k-instance']['ansible_facts']['default_ipv4']['address'] }}:5601"
    - kibana_version: "7.14.0"
  roles:
    - filebeat-role
  tags: filebeat
```

License
-------

MIT

Author Information
------------------

The role was created by Sergey Shadurskiy in 2022/02 as a homework during a 10-month DevOps cource on Netology online educational platform.

