---
layout: post
title:  Ruby super super() 
date:   2018-05-07
categories: Ruby
---

override 父类方法时, 可以用 `super` 来调用父类原来的方法.

`super` 会把当前的参数原样的复制给父方法, `super()` 就明确的用空参数调用父方法.

在 `define_method` 和 `define_singleton_method` 等方法定义中, 必须使用带小括号的明确传参.


```ruby
class C1
  def say(name = nil)
    str = ""
    str += "hello #{name}, " if name
    str += "this is C1. "

    p str
  end
end

class C2 < C1
  def say(name)
    super

    p "this is C2."
  end
end

obj = C2.new
obj.say("obj")
=begin
"hello obj, this is C1. "
"this is C2."
=end


obj.define_singleton_method(:say) do
  super("Singleton>>>")
end
obj.say
=begin
"hello Singleton>>>, this is C1. "
"this is C2."
=end

```