---
layout: post
title:  Docker 笔记2之centos7安装Docker
date:   2018-12-11
categories: Docker
---

# Install Docker on Centos7

1. 升级系统内核
    [https://icbd.github.io/wiki/linux/2018/12/09/centos7-update-kernel.html](https://icbd.github.io/wiki/linux/2018/12/09/centos7-update-kernel.html)
   
2. 安装依赖

```text
yum install -y yum-utils device-mapper-persistent-data lvm2
```

3. 添加 docker-ce 源

```text
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
``` 

4. 替换加速镜像(可选)

```text
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
```

5. 安装

```text
yum install docker-ce
```

6. 设置开机启动并启动

```text
systemctl enable docker
systemctl start docker
```

7. 测试hello-world

```text
docker info
docker run hello-world
```