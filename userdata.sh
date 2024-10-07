#!/bin/bash

labauto ansible
ansible-pull -i localhost, -U https://github.com/gnavien/roboshop-ansible main.yml role_name=rabbitmq -e env=${env} &>>/opt/ansible.log
