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

# Unicode的"码位"与"代码单元"
 
在Ruby中, `String#length` 得到的是字符串的字符个数, 
不需要关心底层字符串怎么实现, 不用关心是普通字符还是辅助字符,
得到的字符个数就是我们所看到的字符个数, 一个Emoji就算一个字符.

```ruby
puts "中👍文".length
# => 3
```

但是Java中会稍微复杂一点, 或者说底层一些, `String#int` 得到的是 Unicode 的代码单元的个数.
```java
public class Main {
    public static void main(String[] args) {
        System.out.println("中👍文".length());
    }
}
// => 4
```

要是想得到视觉所见的字符个数, 应该使用码位来数:

```java
public class Game {
    public static void main(String[] args) {
        String str = "中👍文";
        System.out.println(str.codePointCount(0, str.length()));
    }
}
// => 3
```
