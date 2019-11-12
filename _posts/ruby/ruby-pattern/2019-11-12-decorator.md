---
layout: post
title:  Ruby Decorator 装饰者模式
date:   2019-11-12
categories: Ruby
---

双十一刚过, 小正收到了眼花缭乱的衣服和化妆品. 衣服作为装饰物, 按照顺序依次对她进行装饰.

欲表达一种需求: 先穿白色T恤, 再穿黑色短裙, 最后展示看效果.

让用户接口呈如下的形式:

```ruby
wear TShirt, '白色'
wear Skirt, '黑色'

look Beauty.new('领导')
``` 

其实思路很简单, 我们维护一个栈, 每次 `wear` 的时候, 把装饰物记录到栈里.
等所有的 `wear` 完成了, 衣服就都准备好了, 等到要展示效果的时候, 就把他们一件一件展示出来.

这里的关键特性是: 给 Beauty 穿衣服的时候, 不需要修改 Beauty .

```ruby
class Beauty
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def call(env)
    env
  end
end

class Clothes
  attr_reader :beauty, :color

  def initialize(beauty, color: 'colorless')
    @beauty = beauty
    @color = color
  end

  def call(env = [])
    env << { type: self.class, color: color }
    beauty.call(env)
  end
end

class TShirt < Clothes
end
class Skirt < Clothes
end

module Wear
  def wear(clothes_klass, *args, &block)
    wearables << proc { |beauty| clothes_klass.new(beauty, *args, &block) }
  end

  def look(beauty)
    beauth_with_clothes = beauty
    @wearables.reverse.each do |wearable|
      beauth_with_clothes = wearable.call(beauth_with_clothes)
    end
    # same as:
    # beauth_with_clothes = @wearables.reverse.inject(beauty) { |beauth_with_clothes, wearable| wearable[beauth_with_clothes] }

    env_result = beauth_with_clothes.call
    puts describe(beauty, env_result)
  end

  private

  def wearables
    @wearables ||= []
  end

  def describe(beauty, env)
    "#{beauty.name}今天穿的是: " + \
      env.map { |item| "#{item[:color]}的#{item[:type]}" }.join(', ') + \
      '.'
  end
end
class Show
  extend Wear

  wear TShirt, color: '黑色'
  wear Skirt, color: '紫色'
  look Beauty.new('小正')
end

Show.new
```