---
layout: post
title:  docker build
date:   2018-03-28
categories: docker
---

## 编写 Dockerfile

```
$ vim Dockerfile
```

```
FROM wwwicbd/dev:latest
MAINTAINER @CbdFocus
COPY html/ /usr/share/nginx/html/
ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
```

## build 新镜像

```
$ docker build -t nginx .
Sending build context to Docker daemon  333.8kB
Step 1/4 : FROM wwwicbd/dev:latest
 ---> e6c137eaca9b
Step 2/4 : MAINTAINER @CbdFocus
 ---> Running in 4d737962b2a5
Removing intermediate container 4d737962b2a5
 ---> 1abd28a0d187
Step 3/4 : COPY html/ /usr/share/nginx/html/
 ---> fe273cca47b7
Step 4/4 : ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon off;"]
 ---> Running in 39bee1fa2f52
Removing intermediate container 39bee1fa2f52
 ---> 17e3b992005c
Successfully built 17e3b992005c
Successfully tagged nginx:latest
```

## 运行容器

```
$ docker run -d -p 8080:80 --restart=always 17e3b992005c
e83c41a16f5dfa15de48adb4080074106a5feedac7a5adfccfed305f33938b71
```

## 查看容器

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
e83c41a16f5d        17e3b992005c        "/usr/sbin/nginx -g …"   55 seconds ago      Up About a minute   0.0.0.0:8080->80/tcp   upbeat_cray
$ docker top e83c41a16f5d
PID                 USER                TIME                COMMAND
7451                root                0:00                nginx: master process /usr/sbin/nginx -g daemon off;
7478                998                 0:00                nginx: worker process
7479                998                 0:00                nginx: worker process
```

## 注意

docker run 中的 `-d` 意思是:

> https://docs.docker.com/engine/reference/commandline/run/
> --detach , -d		Run container in background and print container ID

不是 daemon 的意思!!! 也就是说它仅仅把命令放到后台执行, 一旦命令完成, 容器即完成.

所以 ENTRYPOINT 中 nginx 一定要使用 `daemon off;` 模式运行, 让 nginx 常驻前台, 容器就不会自动结束了.

如果怕容器意外中断, 可以在 run 参数里加 `--restart=always` , 会令该容器随docker启动自动重启. 当然 `docker stop hash` 可以让它暂时停下来.

## Dockerfile 的 RUN CMD 和 ENTRYPOINT

#### 相同点:

都支持这两种格式:

```
COMMAND <command>
COMMAND ["executable","param1","param2"]
```

第一种格式实际上相当于: `/bin/sh -c command` .

第二种格式实际上是 JSON, 所以必须用双引号. 不会默认使用 shell, 所以不能写成 COMMAND ["echo", "$PATH"] .

#### 不同点:

`RUN` 用于构建 IMAGE 的命令, 可以使用多次. 每次运行都是在之前层次上的叠加.

`CMD` 和 `ENTRYPOINT` 用于运行容器的命令, 每条只能使用一次, 可以同时存在.
`CMD` 会被命令行参数覆盖, `ENTRYPOINT` 不会.