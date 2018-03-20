---
layout: post
title:  "OSX 10.11使用Composer"
date:   2016-06-03
categories: 工具
---

# 安装

```
curl -sS https://getcomposer.org/installer | sudo php5 -- --install-dir=/usr/local/bin --filename=composer
```

## 注意
1. 安装目录一定不要选 /usr/bin 
2. php5 (/usr/bin/php 即:系统自带的5.5.34),用源码安装的php7.0.6会报下面错误 (不知道是不是我php7的配置有问题~)

```
Fatal error: Allowed memory size of 134217728 bytes exhausted (tried to allocate 8070450532247928936 bytes) in - on line 723
```