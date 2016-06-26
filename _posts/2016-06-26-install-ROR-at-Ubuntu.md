---
layout: post
title:  Install Ruby On Rails at Ubuntu 14.04
date:   2016-06-26
categories: ROR
---


# 系统版本
> Ubuntu 14.04.1 LTS (GNU/Linux 3.13.0-32-generic x86_64)

# 更换163apt源

```
cd ~
curl -O http://mirrors.163.com/.help/sources.list.trusty

cd /etc/apt
sudo cp source sources.list sources.list.bak
sudo rm sources.list
sudo co ~/sources.list.trusty sources.list

sudo apt-get update
```

# 安装常用依赖

```
sudo apt-get install -y curl
curl -sSL https://git.io/vVHhe | bash
```

# 安装RVM和Ruby,修改为ruby-China源

` MIRROR=1 curl -sSL https://git.io/vVHhJ | bash `

# 安装Nginx

` curl -sSL https://git.io/vVHhf | bash `

启动: sudo service nginx start

配置: /etc/nginx

# 参考
> https://ruby-china.org/wiki/deploy-rails-on-ubuntu-server