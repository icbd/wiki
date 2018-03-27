---
layout: post
title:  yum只在一个repo中搜索
date:   2018-03-27
categories: notes
---

```
查看正在使用的repo
yum repolist

查看所有安装的repo
yum repolist all

启用某个repo
yum-config-manager --enable extra

禁用某个repo
yum-config-manager --disable extra

列出某个package(在所有可用的repo中搜索)
yum list \*nginx\*

列出某个package(在某个特定的repo中搜索; 先禁用所有, 再开启特定的repo)
yum --disablerepo="*" --enablerepo="epel" list \*nginx\*
```