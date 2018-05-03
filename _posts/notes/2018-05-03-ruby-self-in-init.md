---
layout: post
title:  Ruby initialize 中的self
date:   2018-05-03
categories: Ruby
---

"元编程"动态方法一章, 有这么一个例子(摘了其中一部分):

```
class MyClass
  def initialize
    MyClass.class_func
  end

  def self.class_func
    define_method(:hello) do |param|
      p param
    end
  end
end

obj = MyClass.new
obj.hello("hh")
```

注意第三行, 这样有一个硬编码的 `MyClass`, 于是想消除它.

首先换成了 `self.class_func`, 运行一下报方法找不到.

开始还以为是加载顺序的问题, 后来意识到是 `self` 用错了.

正确的写法是 `self.class.class_func`.


```
class MyClass
  def initialize
    p "init start>>"
    self.class.class_func
    p "self at init: ", self
    p "init end>>"
  end

  def self.class_func
    p "define self.class_func>>"
    define_method(:hello) do |param|
      p param
    end
  end
end

obj = MyClass.new
obj.hello("hh")

p obj
p MyClass.new
```

该程序的结果如下:

```
"init start>>"
"define self.class_func>>"
"self at init: "
#<MyClass:0x007f98bb1847b8>
"init end>>"
"hh"
#<MyClass:0x007f98bb1847b8>
"init start>>"
"define self.class_func>>"
"self at init: "
#<MyClass:0x007f98bb1841a0>
"init end>>"
#<MyClass:0x007f98bb1841a0>
```

## 结论:

initialize 中的 self 即 MyClass.new 的对象.

在 initialize 中调用类方法应该使用 `self.class.class_method`