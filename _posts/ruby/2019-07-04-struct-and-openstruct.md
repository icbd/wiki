---
layout: post
title:  Struct and OpenStruct
date:   2019-07-04
categories: Ruby
---

## Struct

Struct 的优点是可以方便地封装数据, 对于调用者来说使用方式也更随意, 支持以方法的形式或者哈希或者数组.

当class的入参是一个复杂的数据结构时, 我们可以用 Struct 作为中转对象.

Struct 可以帮助我们以极低的成本实现 `依赖行为而不是依赖数据` , 将原始的复杂数据结构跟实际的使用分割开, 
当数据结构发生改变时, 只需要修改Struct而不用修改业务逻辑. 


```ruby
Struct.new('Person1', :name, :age)
mike = Struct::Person1.new("Mike")
mike.age = 30


Person2 = Struct.new(:name, :age)
john = Person2.new('John', 18)
john2 = Person2['John2', 8]


Person3 = Struct.new(:name, :age, keyword_init: true)
bob = Person3.new(name: 'Bob')
bob.age = 12


Person4 = Struct.new(:name, :age, keyword_init: true) do
  def greet
    "Welcome, this is #{name}"
  end
end
jim = Person4.new(name: 'Jim', age: 29)
jim.greet
jim.name
jim[:name]
jim['name']
jim[0]
jim.dig(:name)
jim.dig('name')

jim.each do |value|
  value
end

jim.each_pair do |key, value|
  key # symbol
  value
end

jim.members # symbol of array
jim.values
jim.to_a
```

## OpenStruct

使用 `OpenStruct` 需要显示 `require "ostruct"` .

`OpenStruct` 更像是一个 Hash, 除了用 `[]` 来取值, 还可以用 `.` 来调用, 把key作为方法名来使用.

`OpenStruct` 不能像 `Struct` 那样在 block 内定义方法.

`OpenStruct` 使用了method_missing 来实现, 效率比 Hash 和 Struct 略差.

```ruby
require "ostruct"

person = OpenStruct.new
person.name = "John Smith"
person.age  = 70

person.name      # => "John Smith"
person.age       # => 70
person.address   # => nil


measurements = OpenStruct.new("length (in inches)" => 24)
measurements.send("length (in inches)")   # => 24

message = OpenStruct.new(:queued? => true)
message.queued?                           # => true
message.send("queued?=", false)
message.queued?                           # => false

```

