---
layout: post
title:  在EI Captain安装Mysql
date:   2016-07-06
categories: Install
---

## 下载DMG

> http://dev.mysql.com/downloads/mysql/

选择版本然后download. (需要登录)

## 安装

一路Next.
最后安装好会弹窗,给一个mysql的初始ROOT密码.
万一手抖划过去也不要紧,在通知中心也还能找到.

![ROOT Init Password](/wiki/wiki/mysql_init_pw.png)

## 启动

![start mysql](/wiki/wiki/start_mysql.png)

## 添加PATH

在 ` ~/.bash_profile` 文件中追加

```
export PATH=/usr/local/mysql/bin:${PATH}
```

刷新 `$ source  ~/.bash_profile`

查看 `$ which mysql`

## 修改ROOT密码

```
# 进入
$ mysql -u root -p

# 修改
> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new_password');

```





