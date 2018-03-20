---
layout: post
title:  Linux command base64
date:   2017-10-11
categories: Linux
---

```

# 对某文件的内容进行编码
base64 fileName

# 对某文件的内容进行解码
# -i ignore non-alphabet characters
base64 -d fileName

# 对字符串编码
# echo 的 -n 表示结尾不输出换行
echo -n "hello" | base64

# 对字符串解码
echo -n "aGVsbG8=" | base64 -d

```