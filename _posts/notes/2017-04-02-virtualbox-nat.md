---
layout: post
title:  virtualbox ssh with NAT
date:   2017-04-02
categories: notes
---

# NAT SSH
在可以控制路由器的条件下我喜欢用桥接, 这样会由路由器分配一个192.*.*.*的 IP, 局域网内的机器都可以访问这台 VM.
但如果不方便控制路由器就只能选 NAT 方式, virtualbox的 NAT 默认配置 ssh 连不上.

## 解决方案

使用virtualbox的端口转发.

![virtualbox-nat.png](/wiki/wiki/virtualbox-nat.png)

使用ssh 的 -p 参数:

```
$ ssh login_name@127.0.0.1 -p 2222
```

# Share Folder


1) 安装编译工具

```
$ sudo apt-get install make gcc linux-headers-$(uname -r)
```

2) 装载扩展工具盘
Devices > Insert Guest Additions CD image

3) mount

```
$ sudo mount /dev/cdrom /media/cdrom
```

4) 安装 Vbox 工具

```
$ sudo /media/cdrom/VBoxLinuxAdditions.run
```

5) 设置宿主机共享目录

![vbox-share-folder.png](/wiki/wiki/vbox-share-folder.png)

6) 添加用户到vboxsf 组, 重启

```
$ sudo usermod -a -G vboxsf your_user
$ sudo shutdown -r now
```

7) link

```

$ ln -s /media/sf_vmshare/ ~/vmshare
```

