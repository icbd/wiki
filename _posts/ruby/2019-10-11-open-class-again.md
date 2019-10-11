---
layout: post
title:  再看 Ruby 打开类
date:   2019-10-11
categories: Ruby
---

```ruby
class String
  def hi
    puts "Hi, #{self}"
  end
end

"Focus".hi
#=> Hi, Focus
```

这是一个基本的 Ruby 打开类. 像这样打开 String 后添加 `hi` 方法, 会影响之后的所有 String 对象.

如果我们想减小这种影响, 可以使用 refinement 技术: `refine` 和 `using`.

我们定义一个 `MyPatch` 的命名空间(一个module):

```ruby
module MyPatch
  refine String do
    def hi
      puts "Hi, #{self}"
    end
  end
end
```

在需要使用 `hi` 方法的命名空间内, 通过 `using` 来使其生效:

```ruby
class Pet
  using MyPatch
  attr_accessor :name

  def initialize(name:)
    @name = name
  end

  def greet
    name.hi
  end

  def self.hello
    "abc".hi
  end
end
```

发现 `hi` 仅能在 Pet 内使用, 在其他的作用域 String 是没有 `hi` 方法的:

```ruby
Pet.hello
# => Hi, abc
doudou = Pet.new(name: 'DouDou')
doudou.greet
# => Hi, DouDou
doudou.name.hi
# => undefined method `hi' for "DouDou":String (NoMethodError)
```

从语法上可以看到区别, `class` 是一个保留字, 用来把你带入到这个类的上下文中.

`class` 的副作用是当该类不存在时, 新建这个类; 当该类存在时, 打开这个类, 不新建类.

`refine` 后面还有 `do`, 是 `Module` 的一个私有实例方法:

```ruby
Module.private_instance_methods.grep(/^refine/)
#=> [:refine]
``` 

`using MyPatch` 的影响范围被约束在 `Pet` 内, 可以用于 Pet 的类方法 和 Pet 的实例方法.

使用 `refine` 和 `using`, 可以有效减少打开类带来的副作用.

## 题外话

```ruby
module MyPatch
  class String
    def hi
      puts "Hi, #{self}"
    end
  end
end

class Pet
  include MyPatch

  def self.hello
    'abc'.hi
  end
end

Pet.hello
```

如果我们这样写会怎么样呢?

`undefined method `hi' for "abc":String (NoMethodError)`

WHY?

```ruby
module MyPatch
  class String
    def hi
      puts "Hi, #{self}"
    end
  end
end

class Pet
  include MyPatch

  def self.hello
    puts 'abc'.instance_of? String # false
    puts 'abc'.instance_of? ::String # true
  end
end

Pet.hello
```

正确的写法:

```ruby
module MyPatch
  class ::String
    def hi
      puts "Hi, #{self}"
    end
  end
end
```

应该指明打开的是顶层的 String, 也就是 `::String`, 否则, class 看到 `MyPatch::String` 不存在, 就新建了一个类.
