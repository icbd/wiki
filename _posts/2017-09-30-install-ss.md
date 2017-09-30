---
layout: post
title:  install ShadowSocks on centos7
date:   2017-09-30
categories: notes
---


install pip

```
yum -y install wget
wget https://bootstrap.pypa.io/get-pip.py

python --version
python get-pip.py
pip --version

pip install shadowsocks

vi /etc/shadowsocks.json
```

shadowsocks.json

```
{
  "server": "server_ip",
  "server_port": 8000,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "password": "password",
  "timeout": 300,
  "method": "aes-256-cfb"
}
```


```
ssserver --version
ssserver -c /etc/shadowsocks.json -d start
```

