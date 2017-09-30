---
layout: post
title:  centos7 安装 Ruby on Rails (RoR) 开发环境
date:   2017-09-21
categories: notes
---

# install RoR on centos7

## 安装升级:

```
    yum -y update
```

## 安装常用依赖:

```
    # yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel wget

```

## 安装 rvm ruby bundle rails

(前两步需要科学上网)

```
    # gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

    # \curl -sSL https://get.rvm.io | bash -s stable

    # source /etc/profile.d/rvm.sh
    # rvm -v
    # rvm requirements
    # rvm install ruby 2.4.1
    # rvm use 2.4.1 --default

    # gem sources --add https://gems.ruby-china.org/ --remove [https://rubygems.org/](https://rubygems.org/)
    # gem sources -l
    # gem install bundle

    # vi ~/.gemrc
    gem: --no-rdoc --no-ri

    # gem install rails
```

## 安装 mysql5.6.37:

```
    # wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
    # rpm -ivh mysql-community-release-el7-5.noarch.rpm
    # yum install mysql-server
    # systemctl start mysqld
    # mysql_secure_installation
```

## 配置 mysql 远程连接:

(比较粗糙, 直接关掉防火墙)

```
    # systemctl stop firewalld.service
    # systemctl disable firewalld.service

    # mysql -uroot -p
    > use mysql;
    > update user set host='%' where user = 'root';
    > flush privileges;
    > exit
```