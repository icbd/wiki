---
layout: post
title:  "Jekyll on Github markdown图片"
date:   2016-06-04
categories: 工具
---

看到几个基于Jekyll的Github页面都采用外链的方式管理图片.
七牛有提供免费空间,速度也不错,但操作总是稍显繁琐.


完全可以直接把图片放到Jekyll项目下来管理,把Github当做图床.

1. 在项目根目录下新建`wiki/`,所有图片都放在这儿或者再新建子目录
2. 在Markdown文件中这样引用图片:

```
![@CbdFocus](/wiki/wiki/face.jpeg)
```

其中`wiki`为本项目名.