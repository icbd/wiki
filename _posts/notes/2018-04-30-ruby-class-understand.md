---
layout: post
title:  理解Ruby的类
date:   2018-04-30
categories: Ruby
---

## 从类的角度观察 `String`:

继承:

```
?> String.superclass
=> Object
>> String.superclass.superclass
=> BasicObject
>> String.superclass.superclass.superclass
=> nil
>> String.superclass.superclass.superclass.superclass
NoMethodError: undefined method `superclass' for nil:NilClass
```

nil 是 `NilClass` 的对象, 不是类, 没法响应 `superclass` 方法.

## 从对象的角度观察 `String`:

实例化:

```
?> String.class
=> Class
>> String.class.class
=> Class
```

任意类都是 `Class` 类的实例对象.


## Class 类

`Class` 类继承自 `Module` 类;
`Class` 由 `Class` 对象实例化产生.

```
>> Class.superclass
=> Module
>> Class.ancestors
=> [Class, Module, Object, Kernel, BasicObject]
>> Class.class
=> Class
```

## 小结:

```
module MyModule
  def say
    "this is MyModele"
  end
end

class MyClass
  def say
    "this is MyClass"
  end
end

p MyModule.is_a?(Module) #true
p MyClass.is_a?(Class) #true

puts "MyModule 由 Module 类产生:"
p MyModule.class # Module
p MyModule.class.class # Class
p MyModule.class.class.class # Class
p MyModule.superclass rescue p "MyModule 不是类, 没法响应superclass方法"

puts "MyClass 由 Class 类产生:"
p MyClass.class # Class
p MyClass.class.class # Class
p MyClass.class.class.class # Class
p MyClass.superclass # Object

puts "Class 类继承自 Module 类:"
p Class.superclass  # Module
```

## 一种比喻:

String类就好比一个机床, 它可以**制造**一种字符串零件.

String机床的**设计**继承自Object机床.

String机床是由Class机床**制造**出来的.

Class机床是由Class机床**制造**出来的.

Class机床的**设计**继承自Module机床, Module机床的**设计**继承自Object机床.