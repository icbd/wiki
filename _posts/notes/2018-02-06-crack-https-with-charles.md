---
layout: post
title:  用 Charles 撕破 HTTPS
date:   2018-02-06
categories: notes
---

## About Charles

> Charles is a web proxy (HTTP Proxy / HTTP Monitor) that runs on your own computer.
> Your web browser (or any other Internet application) is then configured to access the Internet through Charles,
> and Charles is then able to record and display for you all of the data that is sent and received.

### SSL Proxying

> Charles can act as a man-in-the-middle for HTTP/SSL communication,
> enabling you to debug the content of your HTTPS sessions.



## 原理

![Charles-principle.png](/wiki/wiki/Charles-principle.png)

## 操作

1. 下载&&安装

[https://www.charlesproxy.com/download/](https://www.charlesproxy.com/download/)

2. 安装根证书(on MacOS)

> help => SSL Proxying => Install Charles Root Certificate

When using this certificate: Always Trust.

![Charles-cert.png](/wiki/wiki/Charles-cert.png)

3. 安装客户端证书(on IOS)

> help => SSL Proxying => Install Charles Root Certificate on a Mobile Device or Remote Browser

先将 Mac 和 IPhone 连接到同一网段下(同一个WIFI), 根据提示, 在 IOS 中找到: 设置 => 无线局域网 => 配置代理 => 手动


Charles 菜单: Proxy => Proxy Setting

![proxy-setting.png](/wiki/wiki/proxy-setting.png)


设置好 Proxy 的地址和端口.

在手机浏览器中访问 [chls.pro/ssl](chls.pro/ssl) 安装证书, 信任证书.

最新版本的IOS还需要手动启用证书.

4. 添加 SSL Proxying Settings

添加想要监测的域:

> Proxy => SSL Proxying Settings => Add

也可以使用通配符: `*:*`

5. 配合 shadowsocks

当需要在手机上抓被墙的网站时, 可以让 Charles 使用外部代理(Shadowsocks).

![charles-ss.png](/wiki/wiki/charles-ss.png)