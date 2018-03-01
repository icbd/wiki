---
layout: post
title:  Install centos 7 with USB
date:   2018-03-01
categories: notes
---

# 真机U盘安装 Centos7

## 制作安装U盘

下载ISO镜像文件, 使用软碟通烧录.
打开ISO文件 => 启动 => 写入硬盘映像 => usd+hdd

## 进BOIS, 手动指定镜像文件

根据提示编辑启动选项(新版是`e`键)
修改 `vmlinuz initrd` 选项为 `vmlinuz initrd=initrd.img inst.stage2=hd:/dev/sdc4 quiet`
`ctrl+x` 确定修改

## 进入安装界面
