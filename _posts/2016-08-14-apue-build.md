---
layout: post
title:  APUE编译错误
date:   2016-08-14
categories: APUE
---

直接 `gcc ls.c` 会报找不到'apue.h'的错, 放到一个目录下又找不到 err_quit 函数.

'apue.h' 文件是作者自己写的头文件, 需要手动引入.

'err_quit' 等几个方法也是.

## 我是这样做的:

1) 下载APUE 3E 的[source code](http://www.apuebook.com/src.3e.tar.gz)

2) 修改'apue.h'文件, 添加 `include 'error.c' `

3) 复制到GCC的自动查找目录下

```
$ sudo cp apue.h /usr/local/include/apue.h
$ sudo cp error.c /usr/local/include/error.c
```
重启terminal. 这时用GCC已经可以正确连接编译了.

4) 如果用Xcode, 还是会提示红色叹号找不到'apue.h'.

![build setting](wiki/wiki/buildSetting.png)



