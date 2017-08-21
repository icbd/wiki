---
layout: post
title:  Unicode字符平面映射
date:   2017-08-21
categories: notes
---



> 一个字节8位,用2个十六进制字符表示.

65536(2^16)个字符一个平面,共17(2^5)个平面,Unicode字符集容量2^21.

基本多文本平面BMP在第0号平面,U+0000 ~ U+FFFF.

其余字符都在辅助平面,总量为2^21 - 2^16不足2^20以2^20算.

2^20可以拆成两个2^10,正好在BMP内有两个空段,可以用来映射辅助平面.

U+D800 ~ U+DBFF:空段的高半区

U+DC00 ~ U+DFFF:空段的低半区

第一个固定为D.8~B(8/9/A/B),C~F(C/D/E/F)是4位,后面两位任意(2^4*2^4),共2^2*2^4*2^4=2^10.

表现为，一个辅助平面的字符，被拆成两个基本平面的字符表示.

UTF-32,每个码点占四字节,字节内容一一对应码点.

UTF-16/UTF-8都需要通过转码公式把Unicode码点转到其对应的编码.


## 扩展阅读

> https://en.wikipedia.org/wiki/Plane_(Unicode)
> http://www.ruanyifeng.com/blog/2014/12/unicode.html