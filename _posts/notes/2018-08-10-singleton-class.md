---
layout: post
title:  Ruby 单件类  
date:   2018-08-10
categories: Ruby
---

```ruby
require 'pry'
class C
  single_class = class << self
    def hi
      "hi"
    end

    self
  end

  # C的引用 != 单件类的引用
  p self != single_class

  p single_class
  p single_class.class
  p single_class.superclass
  p self.superclass
  puts '---'
=begin
true
#<Class:C>
Class
#<Class:Object>
Object
=end
end

p C.class
p C.superclass
puts '---'
=begin
Class
Object
=end


# 类的单件方法(类方法)
p C.singleton_class.class
p C.singleton_class.superclass
p C.singleton_class.instance_methods(false) # 该类的类方法即该类的单件类的实例方法
p C.hi
puts '---'
=begin
Class
#<Class:Object>
[:hi]
"hi"
=end

c = C.new
# 类的对象的单件方法(实例方法)
def c.hello
  "hello"
end

p c.singleton_class.class
p c.singleton_class.superclass
p c.singleton_class.instance_methods(false)
p c.hello
puts '---'
=begin
Class
C
[:hello]
"hello"
=end


# binding.pry
puts '---'

# 类方法存在于每个类的单件类中
```