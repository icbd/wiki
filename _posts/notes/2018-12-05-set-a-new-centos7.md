---
layout: post
title:  配置一台新买的centos7
date:   2018-12-05
categories: Linux
---

最近买了一些墙外的新机器, 记录一下对新机器的操作:

```shell

echo "更新软件包"
yum update -y

echo "安装yum工具"
yum install -y yum-utils

echo "安装epel扩展包"
yum install -y epel-release
echo "启用epel的repo"
yum-config-manager --enable epel

echo "安装常用依赖和工具"
yum install -y openssl-devel git-core zlib gcc-c++ patch readline readline-devel libyaml-devel libffi-devel make bzip2 autoconf automake libtool bison curl sqlite-devel net-tools python2-pip telnet nc htop

echo "替换firewalld为iptables"
systemctl disable firewalld
systemctl stop firewalld
systemctl enable iptables
systemctl start iptables

echo "iptables清空默认规则; 放行环回口; 放行http和https; 放行ssh; 放行icmp; 放行相关和已建立的连接; 其余DROP; "
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -p tcp --dport ${SSH_CLIENT##* } -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P INPUT DROP 

service iptables save
```