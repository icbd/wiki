---
layout: post
title:  Focus on Rails: ActiveSupport::Concern  
date:   2018-08-17
categories: Rails
---

初读 Rails 源码的时候, 总是理不清楚各个 module 之间的关系, 这里就从 `ActiveSupport::Concern` 出发, 理一理 Rails 是怎么处理混入的.

# include 和 extend

```ruby
module Module1
  def module1_instance_method
    puts "#{self}: module1_instance_method"
  end

  def self.module1_class_method
    puts "#{self}: module1_class_method"
  end
end

module Module2
  def module2_instance_method
    puts "#{self}: module2_instance_method"
  end

  def self.module2_class_method
    puts "#{self}: module2_class_method"
  end
end

class Class1
  def class1_instance_method
    puts "#{self}: class1_instance_method"
  end

  def self.class1_class_method
    puts "#{self}: class1_class_method"
  end
end

class Demo < Class1
  include Module1
  extend Module2
end
```

类方法实质上是该 类/模块 的单件方法. 

Demo 继承 Class1 , 可以看到 Class1 上的实例方法和类方法.

Demo include Module1 , 将 Module1 中的实例方法添加到 Demo **内**, 作为 Demo 的实例方法, Module1 的类方法不会引入到 Demo **中** .

Demo extend Module2, 将 Module2 中的实例方法添加到 Demo **上**, 作为 Demo 的类方法, Module2 的类方法不会被添加到 Demo **上** .

## included 和 extended

上例可以看出, 普通的 include 只能添加实例方法. 如果想用 module 给 特定的 类 添加类方法, 需要这样变通一下:

```ruby
module Mod
  def mod_instance_method
    puts "#{self}: mod_instance_method"
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def hi
      puts "#{self}: ClassMethods, hi."
    end
  end
end

class Clas
  include Mod
end
```

在 Clas include Mod 之后, 会调用 Mod 上的类方法: included .

此时的 self 是 Mod , base 是 Clas . 主动触发 `Clas.extend ClassMethods` , 将内部模块 ClassMethods 的方法注入到 Clas **上** .


# included VS append_features

`included` 在 include 完成时回调, 本身是个空方法.

`append_features` 本身就是来处理 include 的, 重载此方法时务必要 `super`, 否则不会有 include 的效果. 

# 多层模型

对于实例方法, 目的类总是能看到各个模块的方法, 但是类方法就出问题了.

按照上面的方式, 如果含有链式的 include , `Clazz.second_level_class_method` 会抛出 `NoMethodError` . 


```ruby
module SecondLevel
  include ThirdLevel

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def second_level_class_method
      puts ">>>second_level_class_method"
    end
  end
end

module FirstLevel
  include SecondLevel

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def first_level_class_method
      puts ">>>first_level_class_method"
    end
  end
end

class Clazz
  include FirstLevel 
end
``` 

FirstLevel include SecondLevel 的时候, 在 SecondLevel 内的 included 回调, 

self 是 SecondLevel, base 是 FirstLevel, 所以 `second_level_class_method` 被注入到 FirstLevel 上 而不是 Clazz 上.

所以有木有什么办法, 能穿越多层 module 给类添加类方法呢? 也就是让 `self.included(base)` 的 base 总是指向 Clazz 呢? 

# ActiveSupport::Concern 用法示例

```ruby
require "active_support/concern"

module ThirdLevel
  extend ActiveSupport::Concern

  included do
    def third_level_instance_method
      puts ">>>third_level_instance_method"
    end
  end

  class_methods do
    def third_level_class_method
      puts ">>>third_level_class_method"
    end
  end

end

module SecondLevel
  extend ActiveSupport::Concern

  include ThirdLevel

  included do
    def second_level_instance_method
      puts ">>>second_level_instance_method"
    end
  end

  class_methods do
    def second_level_class_method
      puts ">>>second_level_class_method"
    end
  end

end

module FirstLevel
  extend ActiveSupport::Concern

  include SecondLevel

  # 被添加为实例方法
  def first_level_instance_method
    puts ">>>first_level_instance_method"

    # 依赖第二层的类方法
    puts self.class.second_level_class_method
  end

  # 被添加为类方法
  module ClassMethods
    def first_level_class_method
      puts ">>>first_level_class_method"
    end
  end
end

class Clazz
  include FirstLevel
end
```

# ActiveSupport::Concern 源码分析

```ruby
module ActiveSupport
  module Concern
    class MultipleIncludedBlocks < StandardError #:nodoc:
      def initialize
        super "Cannot define multiple 'included' blocks for a Concern"
      end
    end

    def self.extended(base) #:nodoc:
      base.instance_variable_set(:@_dependencies, [])
    end

    def append_features(base)
      if base.instance_variable_defined?(:@_dependencies)
        base.instance_variable_get(:@_dependencies) << self
        false
      else
        return false if base < self
        @_dependencies.each { |dep| base.include(dep) }
        super
        base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
        base.class_eval(&@_included_block) if instance_variable_defined?(:@_included_block)
      end
    end

    def included(base = nil, &block)
      if base.nil?
        raise MultipleIncludedBlocks if instance_variable_defined?(:@_included_block)

        @_included_block = block
      else
        super
      end
    end

    def class_methods(&class_methods_module_definition)
      mod = const_defined?(:ClassMethods, false) ?
                const_get(:ClassMethods) :
                const_set(:ClassMethods, Module.new)

      mod.module_eval(&class_methods_module_definition)
    end
  end
end
```

先加载 ThirdLevel , 顺序执行到 `extend ActiveSupport::Concern` 触发 extended 回调,
此时的 base 是 ThirdLevel , self 是 Concern , 在 ThirdLevel 上设置实例变量 `@_dependencies` 为空数组 .


之后加载 SecondLevel , 同样设置了实例变量 `@_dependencies` 为空数组. 
在 SecondLevel 内 include ThirdLevel,  触发 ThirdLevel 上的 append_features , 此时 self 是 ThirdLevel , base 是 SecondLevel .
执行 if 流程, 将 ThirdLevel 加入 到 SecondLevel 对应的 `@_dependencies` 数组中 , 返回 false . 
特别注意, if 流程中没有调用 super , 也就是说 SecondLevel 的方法还没有加入到 FirstLevel 内, if 流程只是做了模型依赖的数据准备.

之后加载 FirstLevel , 同样设置了实例变量 `@_dependencies` 为空数组.
在 FirstLevel 内 include SecondLevel, 触发 SecondLevel 上的 append_features , 此时 self 是 SecondLevel, base 是 FirstLevel .
执行 if 流程, 将 SecondLevel 加入到 FirstLevel 对应的 `@_dependencies` 数组中, 返回 false .

之后加载 Clazz, Clazz上 没有设置实例变量 `@_dependencies`. 
Clazz include FirstLevel, 触发 FirstLevel 上的 append_features , 此时 self 是 FirstLevel, base 是 Clazz . 
执行 else 流程, `if base < self` 是判断 self 是否是在 base 的祖先链上, 如果是就直接返回. 此时 FirstLevel 并不在 Class 的祖先链上.

Concern 的重点在 `@_dependencies.each { |dep| base.include(dep) }` .
此时 self 是 FirstLevel , 他的 `@_dependencies` 是 `[SecondLevel]` , 所以这个迭代实际执行的是: `Clazz.include(SecondLevel)` .

然后又会触发 SecondLevel 上的 append_features , base 是 Clazz , 执行其 else 流程. 这个 each 迭代实际执行的是: `Clazz.include(ThirdLevel)` .

然后又触发 ThirdLevel 上的 append_features, base 依然是 Clazz , ThirdLevel 上的 `@_dependencies`  是空数组, 直接来到后面的代码.
super 处理 include 本身的操作, 

```ruby
base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
base.class_eval(&@_included_block) if instance_variable_defined?(:@_included_block)
```

处理实例方法和类方法的注入, base 都是 Clazz .

然后回溯之前的递归, 依次处理好 SecondLevel 和 FirstLevel .

然后就处理好啦 ^_^ 
             


# 参考:

[https://api.rubyonrails.org/classes/ActiveSupport/Concern.html](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)
[https://ruby-china.org/topics/32585](https://ruby-china.org/topics/32585)
[https://ruby-china.org/topics/26208](https://ruby-china.org/topics/26208)

 
 

