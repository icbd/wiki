---
layout: post
title:  Ruby 作用域
date:   2018-05-08
categories: Ruby
---

Ruby的作用域个跟Java很不一样, 每每遇到 `class module def` 时, 会切换到一个截然不同的作用域, 而不是层层嵌套.

## Scope Gate

一旦进入一个新的作用域, 原先的绑定就会被替换为一组新的绑定.

```ruby
a1 = []
p "a1:#{a1.object_id},#{local_variables},#{__LINE__}"

class MyClass
  a2 = []
  p "a2:#{a2.object_id},#{local_variables},#{__LINE__}"


  def func
    a3 = []
    p "a3:#{a3.object_id},#{local_variables},#{__LINE__}"
  end

  p "#{local_variables},#{__LINE__}"
end

obj = MyClass.new
obj.func
obj.func
obj.func

=begin
"a1:70329494446840,[:a1, :obj],2"
"a2:70329494446140,[:a2],6"
"[:a2],14"
"a3:70329494650820,[:a3],11"
"a3:70329494650380,[:a3],11"
"a3:70329494649960,[:a3],11"
=end
```

进入 `class` 关键字时, 作用域从 a1 所在的global作用域切换到 MyClass 类, 所以在 MyClass 内, a1 不可见.

进入 `def` 关键字时, 作用域从 MyClass 类切换到 func 方法, 在 func 内看不到类的局部变量 a2.

obj多次调用func方法, 每次调用都重新初始化一个作用域, 每次看到的a3都是新的的a3.

## Flattening the Scopre

```ruby
def define_methods
  shared = 0

  Kernel.send :define_method, :counter do
    p "counter,#{shared}"
  end

  Kernel.send :define_method, :inc do |x=1|
    p "inc,#{x}"
    shared += x
  end
end

define_methods

counter
inc
counter
inc(100)
counter
```

使用 `send` 向 Kernel 发起动态派发, 新定义 counter 和 inc 方法.

|作用域门有隔离|无隔离|
|---|---|
|class|Class.new|
|module|Module.new|
|def|Module#define_method()|

使用方法来定义 类/模块/方法, 就不会产生作用域门, 局部变量在他们之间可共享. 
因为从形式上来说, shared 的定义和 send 方法的调用是平级的, 没有作用域切换.


