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

配置iptables:

```bash
echo "清空iptables规则"
iptables --flush
iptables --delete-chain
iptables --table mangle --flush
iptables --table mangle --delete-chain

echo "关闭 ICMP"
iptables -I INPUT -p icmp --icmp-type 8 -j DROP

echo "开启部分端口"
iptables --append INPUT --protocol tcp --dport 50000:52000 -j ACCEPT
iptables --append INPUT --protocol tcp --dport 59999 -j ACCEPT

echo "关闭其他规则"
iptables --policy OUTPUT ACCEPT
iptables --append INPUT --match conntrack --ctstate ESTABLISHED,RELATED --jump ACCEPT
iptables --policy INPUT DROP
iptables --policy FORWARD DROP

service iptables save
```
