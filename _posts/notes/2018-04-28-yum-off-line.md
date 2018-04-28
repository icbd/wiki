---
layout: post
title:  YUM 离线安装
date:   2018-04-28
categories: Linux
---

yum有时候在线安装很慢, 或者有的机器只有内网, 就需要离线安装.

下载rpm

```
yum install --downloadonly --downloaddir=.  memcached
```

yum 会把用到的包和它的依赖一起下载下来, 格式是rpm.

将这些 rpm 传到目标机器上, 在该目录下 `yum install sth` 即可离线安装.