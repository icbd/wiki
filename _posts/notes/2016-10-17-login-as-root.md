---
layout: post
title:  root登录Azure Ubuntu
date:   2016-10-17
categories: Linux
---

Azure大陆区的默认账户名是 `azureuser`,无法直接用root登录.

## 设置root密码

```
sudo passwd root
```
之后输入密码再确认.

## 设置SSH

```
sudo vi /etc/ssh/sshd_config

```

修改如下:

```
#PermitRootLogin without-password
PermitRootLogin yes
```

## 重启机器

