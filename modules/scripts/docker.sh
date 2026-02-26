#!/bin/bash
hostnamectl set-hostname docker.devops.com
timedatectl set-timezone Asia/Kolkata
useradd itadmin
echo 111 | passwd --stdin itadmin
echo 111 | passwd --stdin root
echo "itadmin  ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
echo PermitRootLogin yes >> /etc/ssh/sshd_config
systemctl restart sshd
