---
layout: post
title:  Ruby included Again
date:   2019-04-03
categories: Ruby
---

Ruby 的 `Module#included` 和 `Module#append_features` 肯定不陌生了, 再画一下重点.

当 `C1` 类 include `M1` 模块, 期间会调用 `M1.append_features` 这个私有方法;
 之后, 会调用 `M1.included` 这个回调方法.

这句话有几个重点:

  1. `included` 和 `append_features` 方法都是 `M1` **上** 的方法, 是 `M1` 的模块方法, 不是实例方法 .
  
  2. `included` 是一个回调方法. 作用是锦上添花, 内部默认留空没有逻辑.
  
  3. `append_features` 是一个私有方法, 在 include 的过程中自动调用, 其内部实现 include 的功能. 
  如果重载该方法一定记得 `super`, 否则 include 功能会失效.  
  
  
```ruby
module M1
  def included(base)
    p "included(base), base:#{base}, self:#{self}"
  end

  def self.included(base)
    p "self.included(base), base:#{base}, self:#{self}"
  end

  def self.append_features(base)
    p "append_features(base), base:#{base}, self:#{self}"

    super
  end

  def hi
    p 'Hi, this is M1 .'
  end

  def self.hello
    p 'Hello, this is M1 .'
  end
end
```

## 普通的 include

```ruby
class C1
  include M1
end

begin
  obj1 = C1.new
  obj1.hi
  obj1.hello
rescue NoMethodError => e
  p e.to_s
ensure
  p '---'
end

=begin
"append_features(base), base:C1, self:M1"
"self.included(base), base:C1, self:M1"
"Hi, this is M1 ."
"undefined method `hello' for #<C1:0x00007ff8f4948c58>"

=end
```

调用的是 `M1.included` 和 `M1.append_features`, 没有 `M1#included` .

## 级联的 include

```ruby
module M2
  include M1

  def included(base)
    p "included(base), base:#{base}, self:#{self}"
  end

  def self.included(base)
    p "self.included(base), base:#{base}, self:#{self}"
  end

  def self.append_features(base)
    p "append_features(base), base:#{base}, self:#{self}"

    super
  end
end

class C2
  include M2
end

begin
  obj2 = C2.new
  obj2.hi
  obj2.hello
rescue NoMethodError => e
  p e.to_s
ensure
  p '---'
end

=begin
"append_features(base), base:M2, self:M1"
"self.included(base), base:M2, self:M1"
"append_features(base), base:C2, self:M2"
"self.included(base), base:C2, self:M2"
"Hi, this is M1 ."
"undefined method `hello' for #<C2:0x00007ffe98014e30>"

=end
```

先处理 M2 include M1, 调用 `M1.included` 和 `M1.append_features`, 没有 `M1#included`, self 为 M1, base 为 M2 .

再处理 C2 include M2, 调用 `M2.included` 和 `M2.append_features`, 没有 `M2#included`, self 为 M2, base 为 C2 .

## 调用包含 extend 的 include

```ruby
module M3
  extend M1
end

class C3
  include M3
end

begin
  obj3 = C3.new
  obj3.hi
  obj3.hello
rescue NoMethodError => e
  p e.to_s
ensure
  p '---'
end

=begin
"included(base), base:C3, self:M3"
"undefined method `hi' for #<C3:0x00007ff8f492c530>"
=end
```

`M1#included` 方法被 extend 到 M3 上, M3 就 拥有了 `M3.included` .

C3 include 了 M3, 触发 `M3.included` 回调方法, 对于该 `included` 方法, self 为 M3, base 为 C3 . 

更复杂的综合使用参看 `ActiveSupport::Concern` .