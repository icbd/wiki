---
layout: post
title:  读书笔记-TCP/IP详解 卷1:协议
date:   2018-03-07
categories: BookNotes
---


# Ch1 概述

局域网: LAN(Local Area Netword)


TCPIP协议族

|层次|常见协议|协议特点|
|---|---|---|
|应用层|HTTP Telnet FTP|End-to-End|
|传输层|TCP UDP|End-to-End|
|网络层|IP ICMP IGMP|Hop-by-Hop|
|链路层|MAC 802.3 ARP RARP|Hop-by-Hop|


通常, 应用层对应的应用程序是一个用户进程, 下三层在系统内核中执行.

一个互联网(Internet)就是一组通过相同协议族相连在一起的网络.

网桥在链路层上对网络进行互连; 路由器在网络层上对网络进行互连.

ICMP是IP协议的附属协议(同属网络层), 但是ICMP报文被封装到IP数据报中.

`0b 0000 0000` => `0`

`0b 1000 0000` => `2^7=128`

`0b 1100 0000` => `2^7+2^6=192`

`0b 1110 0000` => `2^7+2^6+2^5=224`

`0b 1111 0000` => `2^7+2^6+2^5+2^4=240`

```
A: 0wwwwwww hhhhhhhh hhhhhhhh hhhhhhhh 0.0.0.0 ~ 127.255.255.255
B: 10wwwwww wwwwwwww hhhhhhhh hhhhhhhh 128.0.0.0 ~ 191.255.255.255
C: 110wwwww wwwwwwww wwwwwwww hhhhhhhh 192.0.0.0 ~ 223.255.255.255
D: 1110bbbb bbbbbbbb bbbbbbbb bbbbbbbb 224.0.0.0 ~ 239.255.255.255
E: 11110xxx xxxxxxxx xxxxxxxx xxxxxxxx 240.0.0.0 ~ 255.255.255.255
```

```
A类地址: 8*1-1=7 个网络号, 8*3=24 个主机号
B类地址: 8*2-2=14 个网络号, 8*2=16 个主机号
C类地址: 8*3-3=21 个网络号, 8*1=8 个主机号
D类地址: 8*4-4=28 个多播组号
E类地址: 留待后用
```

TCP segment 报文段
UDP datagram 数据报
IP datagram 数据报
Ethernet frame 帧


> /etc/services
```
The Well Known Ports are those from 0 through 1023.
The Registered Ports are those from 1024 through 49151
The Dynamic and/or Private Ports are those from 49152 through 65535
```

RFC


IANA



# Ch2 链路层

以太网封装/IEEE802.3封装

都使用 8bit/byte*6byte=48bit 的MAC地址.


## 以太网封装

`6byte目的地址` + `6byte源地址` + `2byte类型` + `46~1500byte数据` + `4byteCRC`

以太网帧内数据: 46~1500byte

以太网帧体积: 64~1518byte


|类型值|对应类型|
|---|---|
|0800|IP数据报|
|0806|28byteARP+18bytePAD|
|8035|28byteRARP+18bytePAD|


## SLIP: 串行线路 (IP Serial Line IP)

以END(0xc0)分隔, 在串行线路上对IP数据报进行封装.

缺陷:

- 必须知道对方IP, 无法通知给对方本机IP.
- 数据帧无类型字段. 传输SLIP的串行线路无法同时传输其他协议.
- 无校验和, 校验需要依赖上层协议.

CSLIP, 压缩的SLIP, 对报文首部压缩.

PPP, 点对点串行协议. 比SLIP相比, 增加了1bye协议字段和2byteCRC.


SLIP, CSLIP, PPP 都运行在低速串行链路上.

## 环回接口 (Loopback Interface)

- 传给环回地址的数据都作为IP输入
- 广播/多播的数据报都复制一份到环回接口
- 传给给主机IP地址的数据都送到环回接口


## MTU 最大传输单元

MTU指的是帧中data部分的长度, 即 `单个帧的实际最大负载容量` , 不包括帧头帧尾.

Ethernet MTU: 1500

IEEE 802.3: 1492



# Ch3 IP:网际协议


不可靠,无连接的数据报传送服务.

网络字节序: big endian. 最高位在左边.

IP首部20byte, 最长60byte.

TOS: 服务类型

TTL: 生存时间

IP首部校验和只对本IP数据报的首部负责, 内部负载数据自行负责各自的差错检验.

IP首部始终是32bit的整数倍(占满图例的整行, 每行4byte, 32bit).


|目的IP地址与本机IP地址(或IP广播地址)|匹配|不匹配|
|---|---|---|
|路由|处理|转发|
|主机|处理|丢弃|


IP路由选择是逐跳的, hop-by-hop.

IP路由过程中, 目的IP始终不变, 目的MAC每条都变.


`0.0.0.0` 可以作为源IP, 不可作为目的IP.


查看80端口

```
netstat -antp | grep :80
```


# Ch4 ARP:地址解析协议

ARP/RARP 由以太网封装, 但隶属于链路层.


```
32bit IP地址    ==ARP==>    48bit MAC地址
32bit IP地址    <==RARP=    48bit MAC地址
```

以太网广播所有机器, 以获得目的IP对应的MAC地址.

每个网络接口有一个硬件地址, 在硬件上进行数据帧交换依赖正确的网络接口.

ARP代理: 路由器伪装为目的主机, 将自己的MAC发过去.

免费ARP: 发送ARP查找自己的IP.
确定LAN内自己的IP没有冲突; 通知LAN内其他成员更新ARP Cache.


# Ch5 RARP: 逆地址解析协议

无盘系统子啊引导时获取IP地址.

RARP 在数据链路层广播, 防止路由器转发.


|op字段 2byte|代表含义|
|---|---|
|1|ARP请求|
|2|ARP应答|
|3|RARP请求|
|4|RARP应答|


RARP服务器为用户进程, 与系统无关.



# Ch6 ICMP: Internet控制报文协议

ICMP由IP封装, 但隶属于网络层.

为避免广播风暴, 以下情况不会导致产生ICMP查询报文:

- ICMP差错报文
- 目的地址是广播/多播的IP数据报
- 源地址是广播/多播/环回/零地址的IP数据报
- 链路层广播的数据报
- 不是IP分片的第一片

ICMP分为查询和差错.

ICMP差错报文必须包括生成该差错的IP数据报的IP首部(20~60byte)再追加其后紧跟的8byte内容.


# Ch7 Ping程序






