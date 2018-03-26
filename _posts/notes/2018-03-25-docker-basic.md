---
layout: post
title:  Docker使用基础
date:   2018-03-25
categories: notes
---

docker操作的参数都需要 `REPOSITORY:TAG`, 没TAG时默认 `latest` .

## 安装和提交

```
搜索镜像
docker search centos
查看具体tag https://hub.docker.com


下载镜像
docker pull centos
相当于
docker pull library/centos:latest

各种操作...exit退出

提交变动
docker commit -a "@CbdFocus" -m "basic init" 5961ab5a410c wwwicbd/cent7:latest

推送到 hub.docker.com
docker push wwwicbd/cent7
```


## 具体操作

```
查看镜像
docker images


查看在运行的容器
docker ps


查看历史所有的容器
docker ps -a


删除容器(不能删在运行的)
docker rm containerID


删除镜像(不能删被依赖的)
docker rmi imageID


删除所有容器
docker rm $(docker ps -a -q)


删除所有镜像
docker rmi $(docker images -q)


检查镜像或容器的详细信息
docker inspect wwwicbd/cent7:1
or
docker inspect 272ba752fbcf


从镜像以交互式启动一个容器
docker run -i -t wwwicbd/cent7:1 /bin/bash
exit 结束退出该容器; CtrlP + CtrlQ 转为守护模式并结束交模式
重新进入该容器
docker attach containerID


从容器历史列表中启动一个容器(-i 为交互模式, 要求原来的容器也是交互式启动的)
docker start -i 1650b29899a8


从镜像启动守护模式的容器
docker run --name CONTAINER_NAME -d IMAGE:TAG

```

