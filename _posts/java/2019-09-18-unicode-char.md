---
layout: post
title:  Java Unicode
date:  2019-09-18
categories: Java
---

```java
public class Game {
    public static void main(String[ \u005d args) {
        // C:\user
        System.out.println("\u2713");
    }
}
```

不出所料, 这段代码会报错. 

但是出人意料的是报错信息: `Error:(3, 16) java: illegal unicode escape` .

如果把注释的这行删掉, 是可以运行并打印一个字符: `✓` .

> Unicode 转义序列会在解析代码之前得到处理.
