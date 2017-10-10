---
layout: post
title:  一键安装 SS 服务器
date:   2017-10-09
categories: notes
---

```
#!/bin/bash

## basic dev tools
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum -y install net-tools bc wget nginx iptables-services git zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel


echo "# SSH 远程登录"
mkdir -p /root/.ssh
chmod 600 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCkXYNI+u037SZ+h/owOikoGXoVuTXk1ENdjml9Ao+Cclwv8gobLLbjwkKROXxRkfA/CheZBLgSMvU8hp1d51HkQSbLzt57D1qd7HgbT1q8Octwg6K2A40sMoFYCTDG6iGbO8VmgwdyPY8ROM9stwquSi74ieyNojT/X9E8wp9r2TsICjRcZ/Q0Hb914gO2ekYwWfRtvHnT2YjgcbcLeg/KFSIdpO9Zfjh57DY790RoYiFBxE8GlWSGM21b6lnebyEyItTBX+oGXQKq1N49DoSFHKY+0EBGEKg1CfEVaOFHGoLFbvtZXXTe4KYZTIJY0mqNV7ecBaZrmU6ILUbEbyd cbd@Baodong-MBP.local" > /root/.ssh/authorized_keys
chmod 700 /root/.ssh/authorized_keys


echo "# 配置 ll 别名"
echo "alias ll='ls -ahlFp'" >>  /root/.bashrc
source /root/.bashrc


echo "# 安装pip, shadowsocks"
mkdir -p /root/source_code
wget -O /root/source_code/get-pip.py https://bootstrap.pypa.io/get-pip.py
python --version
python /root/source_code/get-pip.py
pip --version
pip install shadowsocks


echo "# 安装 ss-bash"
git clone https://github.com/hellofwy/ss-bash.git /root/source_code/ss-bash
echo "export PATH=\"/root/source_code/ss-bash:\$PATH\" " >> /root/.bashrc
source /root/.bashrc


echo "# 弃用 firewalld, 起用 iptables"
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl enable iptables.servic


echo "# 配置 SS Root 账号"
/root/source_code/ss-bash/ssadmin.sh add 10000 password 10G
/root/source_code/ss-bash/ssadmin.sh start
mv /etc/sysconfig/iptables /etc/sysconfig/iptables.bak
touch /etc/sysconfig/iptables
systemctl restart iptables.service

systemctl start nginx.service
```


### vultr.com 优惠码
[https://www.vultr.com/?ref=7227895](https://www.vultr.com/?ref=7227895)

