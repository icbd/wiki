---
layout: post
title:  CSS元素属性选择器
date:   2016-09-06
categories: CSS
---

```
[attr]
```
只要定义了attr属性就会选中.

```
[attr="val"]    绝对匹配
[attr^="val"]   匹配开头
[attr$="val"]   匹配结尾
[attr*="val"]   任意存在匹配
```

不需考虑val格式(无论空格连字符), 整个字符串匹配.


```
[attr~="val"]
```

以空格分隔, 存在完全匹配的即选中(含连字符).

```
[attr|="val"]
```
若属性值为'val'或者是'val-*'的格式, 则选中.

例如:

```
<a class="cl">a link</a>
<a class="cl-b">b link</a>
<a class="c-cl">c link</a>
<a class="cl-">d link</a>
<a class="cl e">e link</a>
<a class="xyz cl-f">f link</a>
```

```
[class|=cl] {
            border:  thin black solid;
        }
```

效果图:

![效果图](/wiki/wiki/cssAttrSelector.png)
