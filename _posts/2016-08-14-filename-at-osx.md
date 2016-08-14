---
layout: post
title:  mac OS 非法的文件名
date:   2016-08-14
categories: OS
---

APUE 3th 说"只有slash和空字符不能出现在文件名中".

表示怀疑, 在mac OS 10.11.6中试验如下.

![at GUI](/wiki/wiki/filename-special-character1.png)

![at Terminal](/wiki/wiki/filename-special-character2.png)

# 总结

1. : colon不能出现在文件名中
2. / slash可以, 但会以 : colon的样子存储
3. `._-+~#%`不需要转义, 其他键盘上的特殊符号均需要
