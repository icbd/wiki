---
layout: post
title:  install sogou on ubuntu 16.04
date:   2016-10-21
categories: tool
---

## 1. 下载搜狗输入法for Linux

[搜狗输入法forLinux](http://pinyin.sogou.com/linux/)

## 2. 安装

在16.04下，双击安装失败。
cd 到deb文件目录下，手动执行安装：

```
sudo apt-get install ./sogoupinyin_2.1.0.0082_amd64.deb 
```

## 3. im-config 

```
im-config
``` 

之后一路yes/next，选项为：fcitx。

![fcitx](/wiki/wiki/im-fcitx.png)

## 4. 重启机器

## 5. fcitx-config-gtk3

```
fcitx-config-gtk3
```

注意取消勾选： `Only Show Current Language`

![sogou](/wiki/wiki/sogou.png)
