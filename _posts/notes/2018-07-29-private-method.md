---
layout: post
title:  Ruby call private method   
date:   2018-07-29
categories: Ruby
---

`private` 方法最核心的特点就是不能明确指定调用者, 只能使用当前默认的self.

```ruby
class C
  attr_reader :name

  def initialize(name = 'Xiaoming')
    @name = name
  end

  def hi(lang = :zh)
    "hi, this is #{@name}"
    rename("小明") if lang == :zh
  end

  private

  def rename(new_name)
    @name = new_name
  end
end

c = C.new

c.send(:rename, "NewName1")
puts c.name

c.instance_eval {rename("NewName2")}
puts c.name

```