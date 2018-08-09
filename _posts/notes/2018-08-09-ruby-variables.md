---
layout: post
title:  Ruby 类变量 类对象的实例变量 类的实例变量  
date:   2018-08-09
categories: Ruby
---

## 类的实例变量 VS 类的对象的实例变量

```ruby
class Person
  # Person类的实例变量, 当前的 self 为 Person
  # 跟Person对象的实例变量无关, 不能交叉访问; Person 子类也不能访问
  @name = "default name"

  def self.name
    # 获得Person类的实例变量
    @name
  end

  # 在定义类时, def 定义的是类的对象的实例方法
  def name=(name)
    # Person的对象的实例变量, 当前的 self 为Person的对象
    @name = name
  end

  def name
    @name
  end
end

class Teacher < Person
end


p Person.name #"default name"
p Teacher.name #nil

name = ""
Person.instance_eval {name = @name}
p name #"default name"

Person.instance_eval {@name = "小红"}
p Person.name #"小红"

one = Person.new
p one.name #nil
one.name = "小明"
p one.name #"小明"
```


## 类变量

```ruby
class Person
  # 类变量在该类的体系内都可以读写, 包括类的对象, 类的子类
  @@name = "default name"

  def self.name
    @@name
  end

  def name=(name)
    @@name = name
  end

  def name
    @@name
  end
end

class Teacher < Person
end

p Person.name #"default name"
p Teacher.name #"default name"

one = Person.new

p one.name #"default name"
one.name = "小明"
p one.name #"小明"

p Person.name #"小明"
p Teacher.name #"小明"

# 在顶层上使用类变量时, 由于main是Object的实例对象, 该类变量会波及Object的所有子类, 慎用!
```