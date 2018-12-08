---
layout: post
title:  Docker 笔记1之缘起
date:   2018-12-01
categories: Docker
---

## 主机级虚拟化

### Type-I

  Hardware -> Hypervisor -> VM

  典型产品: Hyper-v ; Xen ; Vmware ESX/ESXi

### Type-II

  Hardware -> Operation System -> Hypervisor -> VM

  典型产品: VMware Workstion ; VirtualBox ; KVM 


## 容器级虚拟化

依赖内核提供的三个功能: 

### chroot

* 增加系统安全性, 限制用户访问host上原有的根目录结构和文件

* 建立一个与原系统隔离的系统目录结构, 方便用户的开发

* 切换系统的根目录位置，引导 Linux 系统启动以及急救系统等


### namespace

运行服务并不需要独立的内核空间, 但是需要独立的用户空间.


| namespace | resource | resulting |
| --- | --- | --- |
| Mount namespace | 文件系统挂载点 | 每个容器看到不同的文件系统层次 |
| UTS namespace | 节点名称和主机名称 | 每个容器有独立的 hostname 和 domainname |
| IPC namespace | 特定的进程间通信资源 | 容器内进程可通信, 不同容器之间的进程隔离 |
| PID namespace | process ID number space | 跑在容器里的进程有两个PID, 一个是容器中的PID, 一个是host上的PID. |
| Network namespace | 网络资源 | 每个容器有独立的网络设备. IP,IP路由表,/proc/net目录,端口号. |
| User namespace | 用户和组 | 每个容器有独立的用户和组, host上的非特权用户可以是容器中的特权用户 |


用户空间的隔离需要每一种 namespace 的隔离, 依赖Linux内核提供支持, 要求版本不低于 `3.8` .

### Control Groups 

CPU属于可压缩资源, 内存属于不可压缩资源, 资源分配依赖内核功能 -- `CGroups (Control Groups)` .


### LXC

Linux Container 是一个对 Linux 内核功能进行包装的用户空间接口. 
它提供了强大的API和简易的工具集, 让用户方便地创建和管理系统或应用的容器. 

LXC 主要关注系统容器. LXC 尽可能提供一种类似 VM 的环境, 但是没有独立的内核和模拟硬件.

LXC 的实现是通过组合 Linux 内核的一系列安全特性, 比如: namespaces, mandatory access control, control groups .





## 参考

[https://www.ibm.com/developerworks/cn/linux/l-cn-chroot/index.html](https://www.ibm.com/developerworks/cn/linux/l-cn-chroot/index.html)

[https://www.cnblogs.com/sammyliu/p/5878973.html](https://www.cnblogs.com/sammyliu/p/5878973.html)