---
layout: post
title:  Ruby allocate
date:   2018-05-06
categories: Ruby
---

从来没用过 `allocate` 这个方法, 在 "元编程" 中介绍 Class 和 Method 区别时有提及:

```ruby
p Class.instance_methods - Module.instance_methods
#[:new, :allocate, :superclass]
```


`superclass` 用来维护继承链, `new` 用来新建实例, 那 `allocate` 用来做什么呢?


```ruby
klass = Class.new do
  def initialize(*args)
    @initialized = true
  end

  def initialized?
    @initialized || false
  end
end

p klass.allocate.initialized? 
#false
p klass.new.initialized? 
#true
```

## 小结

`allocate` 也用来新建实例, 跟 `new` 不同的是, 它不会调用 `initialize` 方法.

唯一见过 `allocate` 的地方是在 `OpenStruct` 的源码, 用来强制执行 `initialize` 方法.

```ruby
class OpenStruct
  class << self # :nodoc:
    alias allocate new
  end
  
  #...others
end
```