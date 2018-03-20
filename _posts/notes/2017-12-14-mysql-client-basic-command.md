---
layout: post
title:  mysql-client 基础命令
date:   2017-12-14
categories: mysql
---

```
# 显示所有数据库
> show databases;

# 选择一个数据库
> use learn;

# 显示当前所用的数据库
> select database();

# 显示当前数据库下所有表
> show tables;

# 显示时区设置
> select @@global.time_zone, @@session.time_zone;

```


# 配置MySQL支持全部UNICODE(包括Emoji)

> my.cnf

```
[client]
default-character-set = utf8mb4
[mysql]
default-character-set = utf8mb4
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```