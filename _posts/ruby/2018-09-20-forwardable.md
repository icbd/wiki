---
layout: post
title:  Ruby Forwardable Module  
date:   2018-09-20
categories: Ruby
---

[http://ruby-doc.org/stdlib-2.5.0/libdoc/forwardable/rdoc/Forwardable.html](http://ruby-doc.org/stdlib-2.5.0/libdoc/forwardable/rdoc/Forwardable.html)


# Forwardable

`Forwardable` 模块使用 `def_delegator` 和 `def_delegators` 方法, 为指定对象提供特定方法的代理.

例如, 你有一个 `RecordCollection` 的类, 包含实例变量 `@records`. 

你可以提供一个查表方法 `record_number`, 来在数组 `@records` 上调用 `[]`, 如下:

```ruby
require 'forwardable'

class RecordCollection
  attr_accessor :records
  extend Forwardable
  def_delegator :@records, :[], :record_number
end
```

我们可以这样使用查表方法:

```ruby
r = RecordCollection.new
r.records = [4,5,6]
r.record_number(0)  # => 4
``` 

如果你想把 `size << map` 都代理给 `@record`, 可以这样:

```ruby
class RecordCollection # re-open RecordCollection class
  def_delegators :@records, :size, :<<, :map
end

r = RecordCollection.new
r.records = [1,2,3]
r.record_number(0)   # => 1
r.size               # => 3
r << 4               # => [1, 2, 3, 4]
r.map { |x| x * 2 }  # => [2, 4, 6, 8]
```

你甚至可以用 `Forwardable` 扩展标准对象:

```ruby
my_hash = Hash.new
my_hash.extend Forwardable              # prepare object for delegation
my_hash.def_delegator "STDOUT", "puts"  # add delegation for STDOUT.puts()
my_hash.puts "Howdy!"
```

## 其他的例子:

我们希望重用之前的实现, 通过代理, 我们可以只使用一些需要的方法并适当地重命名他们.

在很多情况下, 用代理比继承要好, 继承得到的方法太多了, 很多是我们不需要的.

```ruby
class Queue
  extend Forwardable

  def initialize
    @q = [ ]    # prepare delegate object
  end

  # setup preferred interface, enq() and deq()...
  def_delegator :@q, :push, :enq
  def_delegator :@q, :shift, :deq

  # support some general Array methods that fit Queues well
  def_delegators :@q, :clear, :first, :push, :shift, :size
end

q = Queue.new
q.enq 1, 2, 3, 4, 5
q.push 6

q.shift    # => 1
while q.size > 0
  puts q.deq
end

q.enq "Ruby", "Perl", "Python"
puts q.first
q.clear
puts q.first
```

输出:

```ruby
2
3
4
5
6
Ruby
nil
```

提示: RDoc 不会标注被代理的方法.


# SingleForwardable

`SingleForwardable` 可以用来设置对象层级上的代理.

```ruby
printer = String.new
printer.extend SingleForwardable        # prepare object for delegation
printer.def_delegator "STDOUT", "puts"  # add delegation for STDOUT.puts()
printer.puts "Howdy!"
```

`SingleForwardable` 也能用来给类和模块设置代理:

```ruby
class Implementation
  def self.service
    puts "serviced!"
  end
end

module Facade
  extend SingleForwardable
  def_delegator :Implementation, :service
end

Facade.service #=> serviced!
```

如果你需要同时使用 `Forwardable` 和 `SingleForwardable`,
 最好明确调用 `def_instance_delegator` 和 `def_single_delegator` .


## DIY 例子

```ruby
class Order
  def initialize(origin_price, coupon)
    @origin_price = origin_price
    @coupon = coupon
  end

  def settle
    puts self.class
    @origin_price - @coupon
  end

  def discount_percent
    (1.0 * settle / @origin_price).round(2)
  end

  def self.printer
    "#{self}"
  end
end

require 'forwardable'
class OrderHistory
  extend Forwardable
  extend SingleForwardable

  def initialize
    @order = Order.new(100, 12)
  end

  def_instance_delegator :@order, :settle, :settlement
  # def_delegator :@order, :settle, :settlement

  def_instance_delegators :@order, :settle, :discount_percent
  # def_delegators :@order, :settle, :discount_percent

  # delegate [:settle, :discount_percent] => :@order

  def_single_delegator :Order, :printer, :printer2
end

oh = OrderHistory.new

puts oh.settlement # 88
puts oh.settle # Order 88
puts oh.discount_percent # 0.88

puts OrderHistory.printer2 # Order

```

需要特别注意的是, 调用代理方法的时候, `self.class` 为原类.