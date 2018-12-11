---
layout: post
title:  VirtualBox 网络配置
date:   2018-12-11
categories: notes
---

> For VirtualBox 5.2.22, 

最简单是使用桥接, 但这样每次换路由器都会换IP很不便.

下面使用NAT和HOST-only Adapter混合模式, 实现宿主机和虚拟机互通, 虚拟机之间互通, 虚拟机可连接外网.

## 添加网卡

 1. 在virtualBox的 `Global Tools => create` 里添加一个Host-only Adapter的适配器: `vboxnet0` .
 
 2. 在VM的Settings里, network, adapter2, 添加 `Host-only Adapter`, name 选 `vboxnet0` .

## 重启网卡

新装的机器会自动识别好; 如果是已经装好的机器, 打开 DHCP 再重启网卡.

## centos-release-7-6.1810.2.el7.centos.x86_64

> /etc/sysconfig/network-scripts/ifcfg-enp0s8

```text
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
UUID=bba9ebc1-ee8e-4b79-b989-9e1cbd2fbc9f
DEVICE=enp0s8
ONBOOT=yes
```

重启网卡:

```text
systemctl restart network
``` 

## Ubuntu 18.04.1 LTS

>  /etc/network/interfaces

add:

```text
auto enp0s8
iface enp0s8 inet dhcp
```

重启网卡: 

```text
sudo systemctl restart networking
```
 

详细参阅: [http://www.cnblogs.com/adforce/archive/2013/10/11/3363373.html](http://www.cnblogs.com/adforce/archive/2013/10/11/3363373.html)

