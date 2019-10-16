---
layout: post
title:  Ruby 重新使用被覆盖的方法
date:   2019-10-16
categories: Ruby
---

```ruby
class Pet
  def play
    'Pet play'
  end
end

class Dog < Pet
  def play
    'Dog play'
  end
end
```

Dog 重写了 play 方法, 方法查找时, 会优先找到 `Dog#play` .

对于 Dog 的对象, 他就永远看不到 `Pet#play`, 不过还是有办法来实现:

```ruby
puts Dog.new.play
# => Dog play

Dog.define_method(:play, Pet.instance_method(:play))

puts Dog.new.play
# => Pet play
```

或者影响更小的方法:

```ruby
dog = Dog.new
dog.define_singleton_method(:play, Pet.instance_method(:play))
puts dog.play
# => Pet play

puts Dog.new.play
# => Dog play
```