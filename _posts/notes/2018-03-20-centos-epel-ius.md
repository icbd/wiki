---
layout: post
title:  Centos7使用EPEL和IUS
date:   2018-03-20
categories: notes
---

The IUS Community Project is an effort to package RPMs of the latest stable versions of the most commonly requested software on Red Hat Enterprise Linux and CentOS. IUS provides a better way to upgrade PHP/MySQL/Python/etc on RHEL or CentOS. The project is run by professional Linux Engineers that are primarily focused on RPM Development in the web hosting industry.

IUS依赖EPEL

```
yum install epel-release
```

安装对应系统的RPM

```
yum install https://centos7.iuscommunity.org/ius-release.rpm
```

一键安装Nginx和PHP

```
yum install  php72u-fpm-nginx
```

设置开机启动, 开通防火墙

```
systemctl enable php-fpm
systemctl start php-fpm
systemctl enable nginx
systemctl start nginx

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
```


> [https://ius.io/FAQs/](https://ius.io/FAQs/)