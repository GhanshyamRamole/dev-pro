#!/bin/bash
hostnamectl set-hostname eks
timedatectl set-timezone Asia/Kolkata
useradd itadmin
echo 111 | passwd --stdin itadmin
echo 111 | passwd --stdin root
echo "itadmin  ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
echo PermitRootLogin yes >> /etc/ssh/sshd_config
systemctl restart sshd

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install -y unzip
unzip -o awscliv2.zip
sudo ./aws/install
aws --version

curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client

curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
eksctl version
