---
layout: post
title:  Centos7 上安装最新 Mysql
date:   2019-01-24
categories: Mysql
---

## 移除 老的 mysql repo
```bash
yum remove $(rpm -qa | grep mysql-community-)
```

## 安装官方新 repo: 
[https://dev.mysql.com/downloads/repo/yum/](https://dev.mysql.com/downloads/repo/yum/)

```bash
yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
```

## 安装 mysql

```bash
yum install -y mysql-community-client  mysql-community-server mysql-community-devel

systemctl start mysqld
systemctl enable mysqld
```

## 初始化配置 mysql

查看初始密码:

```bash
cat /var/log/mysqld.log | grep password
```

初始化配置

```bash
mysql_secure_installation
```

禁用远程登录, 防火墙屏蔽3306.

Navicat 使用ssh登录机器, 然后再连接本地mysql.