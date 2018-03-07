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

A: 0wwwwwww hhhhhhhh hhhhhhhh hhhhhhhh 0.0.0.0 ~ 127.255.255.255
B: 10wwwwww wwwwwwww hhhhhhhh hhhhhhhh 128.0.0.0 ~ 191.255.255.255
C: 110wwwww wwwwwwww wwwwwwww hhhhhhhh 192.0.0.0 ~ 223.255.255.255
D: 1110bbbb bbbbbbbb bbbbbbbb bbbbbbbb 224.0.0.0 ~ 239.255.255.255
E: 11110xxx xxxxxxxx xxxxxxxx xxxxxxxx 240.0.0.0 ~ 255.255.255.255

A类地址: `8*1-1=7` 个网络号, `8*3=24` 个主机号
B类地址: `8*2-2=14` 个网络号, `8*2=16` 个主机号
C类地址: `8*3-3=21` 个网络号, `8*1=8` 个主机号
D类地址: `8*4-4=28` 个多播组号
E类地址: 留待后用

TCP segment 报文段
UDP datagram 数据报
IP datagram 数据报
Ethernet frame 帧


> /etc/services
The Well Known Ports are those from 0 through 1023.
The Registered Ports are those from 1024 through 49151
The Dynamic and/or Private Ports are those from 49152 through 65535


RFC


IANA