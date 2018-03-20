---
layout: post
title:  VirtualBox 网络配置
date:   2017-09-08
categories: notes
---

最简单是使用桥接, 但这样每次换路由器都会换IP很不便.
下面使用NAT和HOST-only Adapter混合模式, 实现宿主机和虚拟机互通, 并且虚拟机可以上网这个需求.

## 添加网卡

在virtualBox的GUI里添加一个Host-only Adapter的适配器(默认已经有一个NAT的了)

## 查看网卡

 `$ ls /sys/class/net`

    enp0s3 enp0s8 lo

## 添加配置

 `$ sudo vi /etc/network/interfaces`

    auto enp0s8
    iface enp0s8 inet dhcp

# 重启网络

 `$ sudo /etc/init.d/networking restart`

详细参阅: [http://www.cnblogs.com/adforce/archive/2013/10/11/3363373.html](http://www.cnblogs.com/adforce/archive/2013/10/11/3363373.html)

