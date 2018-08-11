---
layout: post
title:  Ruby methods 查询  
date:   2018-08-11
categories: Ruby
---


对于类来说, `methods` 列举所有可用的类方法, 包括继承来的, extend 来的, 父类 extend 的.

对于普通对象来说, `methods` 列举所有可用的实例方法, 包括继承来的, include 来的, 父类 include 来的.
在普通对象上调用 `methods` 等效于 在该对象的类上调用 `instance_methods` 加 该对象的单件方法: 

```ruby
obj = Clazz.new
obj.methods.sort  == (Clazz.instance_methods + obj.singleton_methods).sort
```



对于类来说, `methods(false)` 列举所有该类的单件方法(也就是类方法), 不包括继承来的, 不包括 extend 来的.

对于普通对象来说, `methods(false)` 列举所有该对象的单件方法, 不包括实例方法, 不包括继承来的.

以上列举的所有方法均不包含 private 方法.
