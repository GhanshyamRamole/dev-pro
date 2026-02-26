#!/bin/bash
useradd itadmin
echo 111 | passwd --stdin itadmin
echo 111 | passwd --stdin ec2-user
echo "itadmin  ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
echo PermitRootLogin yes >> /etc/ssh/sshd_config
systemctl restart sshd
yum update -y
yum install ansible* -y
hostnamectl  set-hostname ansible
mkdir -p /opt/Docker
chown itadmin:itadmin /opt/Docker
cat <<EOF > /opt/Docker/inventory
[Docker]
docker-server

[all:vars]
ansible_port=22
ansible_password=111
EOF

cat <<EOF > /opt/Docker/ansible.cfg
[defaults]
inventory=/opt/Docker/inventory
remote_user=itadmin
host_key_checking=false

[privilege_escalation]
become=true
become_user=root
become_method=sudo
become_ask_pass=false
EOF

chown itadmin:itadmin /opt/Docker/inventory
chown itadmin:itadmin /opt/Docker/ansible.cfg

yum install git -y 
git clone https://github.com/GhanshyamRamole/jenkins-tomcat-proxy-setup.git
sudo bash jenkins-tomcat-proxy-setup/Jenkins-Server-Setup/install_jenkins.sh
sudo bash jenkins-tomcat-proxy-setup/Maven-Setup/install_maven.sh
rm -rf jenkins-tomcat-proxy-setup
mkdir /myproject
chown itadmin:itadmin /myproject

