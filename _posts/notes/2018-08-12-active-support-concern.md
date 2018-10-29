---
layout: post
title:  ActiveSupport::Concern 小结  
date:   2018-08-12
categories: Rails
---


## 预备

先认识几个钩子方法, `extended` `included` 和 `append_features`, 他们是模块上的模块方法.

```ruby
module M1
  def self.extended(base)
    puts "M1 extend by #{base}"
  end
end

module M2
  extend M1

  def hi
    "hi M2"
  end

  def self.append_features(base)
    puts "M2 start append_features to base"
    puts "before super: #{base} included method? #{base.instance_methods.include?(:hi)}"
    super
    puts "after super: #{base} included method? #{base.instance_methods.include?(:hi)}"
  end

  def self.included(base)
    puts "M2 included by #{base}"
  end
end

class Clazz
  include M2
end

=begin
M1 extend by M2
M2 start append_features to base
before super: Clazz included method? false
after super: Clazz included method? true
M2 included by Clazz
=end
```

`extended` 和 `included` 钩子本身是空实现, 重载方法会在 `extend` 和 `include` 完成之后调用.
 
append_features 有本职工作, 负责检查 self 是不是在 base 的祖先链上, 如果不在, 就加进去. 所以重载方法中一定记得 super, 否则 include 无效.

super 之前, 模块的方法还没有引入到类中, super之后, 模块的方法就引入到类中了, 全部完成之后再调用 `included` 钩子.

[http://ruby-doc.org/core-2.5.0/Module.html#method-i-append_features](http://ruby-doc.org/core-2.5.0/Module.html#method-i-append_features)


## 为什么用 `Concern`

在 Ruby 中, 把不同的功能划分到不同的 module 中, 在需要的时候 `include` 或者 `extend`.
这就导致 base 类(把必要的基础功能都组织到 base 类中)特别大特别复杂, 很可能出现多层引用的问题.

多层引用对实例方法没有影响, 无论实例方法散落在哪个模块里, 只要引入了就能使用. 
但是类方法不一样(类方法本质上是该类的单件方法), 穿透多层向某个类添加类方法的时候, 中间层的模块会影响类方法的注入.


`ActiveSupport::Concern` 就解决了这个问题, 可以认为在任何层次的模块中, self 都指向了 base 类.

下面是基本用例:

第一步在 module 中 `extend ActiveSupport::Concern`;

实例方法包在 `included` 的 block 中, 或者不包直接定义.

类方法包在 `class_methods` 的 block 中, 或者使用子模块 `ClassMethods`.


```ruby
require 'pry'
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
  binding.pry
  include FirstLevel
end

puts "---"
```

## 源码分析

先预览一下, 总共就40多行:

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

明白了 `Concern` 的需求后看源码就清楚多了.

本质是想让 self 穿透引用链, 指向 base 类. 
但是语言层级上没有这种支持, 我们需要自己维护一个引用关系, 
在 base 类最后 `include` 的时候, 把维护好的实例方法/类方法一次性注入进来.

具体来说, 在模块 `FirstLevel` 中 `extend ActiveSupport::Concern` 时, 会触发一个钩子:

```ruby
def self.extended(base) #:nodoc:
  base.instance_variable_set(:@_dependencies, [])
end
```

这里的 self 是 `ActiveSupport::Concern`.

这里的 base 是 `FirstLevel`, 对其初始化一个实例变量 `@_dependencies`, 设置为空数组.

extend 之后,  `append_features` `included` `class_methods` 会以类方法注到 `FirstLevel`.

`included` 和 `class_methods` 是可选的, 我们只看 `append_features`: 

首先明确一点, `append_features` 跟 `included` 钩子不同:

`append_features` 本身是有任务的(检查被引入的模块是否在base的祖先链上, 如果不在就加进去), 所以重载之后务必要 `super`;
 
后者本身是空的, 流水都是利润.

```ruby
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
```

现在 `append_features` 是 `FirstLevel` 的类方法了, 这里的 self 是 `FirstLevel`, base 是 `Clazz`.

在执行 `FirstLevel` 的时候, 发现还需要引入 `SecondLevel`.

我们再来看 `SecondLevel`, 它 extend Concern 的时候, 在它上面初始化了 `@_dependencies` 为空数组.

`SecondLevel` 被 `FirstLevel` 引入的时候触发 `append_features(base)`, 此时, self 是 `SecondLevel` , base 是 `FirstLevel`.

所以进入 if 条件, 将 self 加入 `FirstLevel` 的 `@_dependencies` . 返回 false 表明已经在祖先链上了, 不是新的引入.

`Clazz` 上木有初始化过 `@_dependencies`, 进入 else 条件: 如果 self 已经出现在 base 的祖先链上了, 就直接返回 false. 


执行 `@_dependencies.each { |dep| base.include(dep) }` 这句的时候, base 总是 `Clazz`, 达到穿越引用链指向 base 类的目的了.









