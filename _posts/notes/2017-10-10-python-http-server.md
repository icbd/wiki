---
layout: post
title:  开机即用的 http server
date:   2017-10-10
categories: notes
---

Linux 发行版一般不预装 `Ruby` , 但是基本都预装 `Python2.7` .
测试的时候可以使用 Python 标准库中的工具, 比如在8080端口启动一个 Http 服务:

```
python -m SimpleHTTPServer 8080 &
```

