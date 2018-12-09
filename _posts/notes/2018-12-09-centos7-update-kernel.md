---
layout: post
title:  Centos7 升级内核  
date:   2018-12-09
categories: Linux
---

# 添加 elrepo 源

```text
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```

# 查看启动项

```text
cat /boot/grub2/grub.cfg | grep menuentry
```

# 安装 Kernel

```text
yum --enablerepo=elrepo-kernel install kernel-ml
```

# 设默认启动项

```text
grub2-set-default 'CentOS Linux (4.19.8-1.el7.elrepo.x86_64) 7 (Core)'
```

# 重启

```text
reboot
```

# 移除老旧内核

```text
yum remove -y  kernel-3.10.0-957.el7.x86_64
```
