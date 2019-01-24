---
layout: post
title:  使用 Let's Encrypted 为 Nginx(centos) 配置免费 HTTPS 
date:   2019-01-24
categories: notes
---

在开始之前, 务必配置好域名DNS的A记录, 配置好NGINX的server_name.

## 申请认证

```bash

yum install -y epel-release
yum install -y certbot-nginx

certbot --nginx -d example.com -d www.example.com
```

## 定期刷新

```bash
crontab -e

15 3 * * * /usr/bin/certbot renew --quiet
```