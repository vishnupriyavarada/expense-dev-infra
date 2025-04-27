#!/bin/bash
dnf install ansible -y

# push
# ansible-playbook -i inventory.ini mysql.yml

# pull
# we have to run playbook on the same server, so , local host, -U <URL>
ansible-pull -i localhost, -U https://github.com/vishnupriyavarada/expense-ansible-roles-tf.git backend.yaml -e COMPONENT=backend -e ENVIRONMENT=$1