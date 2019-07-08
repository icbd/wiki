---
layout: post
title:  practice-oo-design-in-ruby
date:   2019-06-24
categories: Ruby
---



`设计是保留可变性的艺术, 而非达到完美性的行为.`

## 单一职责的类

什么是易于修改:

* 更改时不会产生意想不到的副作用
* 需求的轻微变化对代码的改动较小
* 现有的代码易于重用
* 添加的代码本身也易于修改



易于修改的代码的特征:  *TRUE*

* 透明(Transparent): 修改代码的后果显而易见
* 合理(Reasonable): 小需求只要小改动
* 可用(Usable): 在不同的环境都可用
* 典范(Examplary): 对后续代码进行示范



高内聚 Hign Cohesive:

单一职责原则, Single Responsibility Principle, SRP .要求该类的所有内容都与其中心目标相关.



DRY 说不要重复自己, 同样的事情不要做几遍. 这不仅仅是节省新代码的工作量, 对修改代码也非常有好处. 在一处定义的行为, 修改一处就可以影响所有, 不容易错而且高效. 这侧面印证了 `要依赖行为, 不要依赖数据` . 数据会在多处被使用, 而特定的行为只会定义在一处. 所以, 最好将内部数据结构隐藏起来, 都通过方法向外暴露.

DRY 原则也暗示我们不要直接操作复杂的数据结构(比如从一个复杂的array里按照位置取值), 而是定义一个方法, 由该方法统一向外提供数据. 这样的好处, 其一是不需要重复自己做取值的脏操作, 再就是可以只修改一处取值行为来从容应对数据结构的变化.



## 依赖关系

迪米特法则(Law of Demeter), 又叫 最少知识原则(Least Knowledge Principle), 应该让一个对象关注自身, 不需要过多的了解别的对象(不和陌生人说话).

多个类之间依赖过多的后果是让多个分离的类看起来像是一个整体, 迫使他们同步移动一起修改, 解决办法就是编写松耦合的代码.



"依赖注入" Dependency Injection, 要求将依赖隔离到类的外部, 由其他类负责初始化数据, 自己的类直接使用其他类的实例对象上的方法. 

应该把依赖看做是一种来自外部的可能有缺陷的外来入侵者, 要求他们对类的影响尽量简单, 以方便安全隔离.

之前讲过将数据用行为封装的意义, 类似的, 将对依赖的调用封装成自己的方法再使用也很有帮助.



## 灵活的接口

设计应该关心对象之间传递的消息.

需要解决对象自己所知道的内容(职责), 也要解决对象知道谁的问题(依赖关系), 还要解决他们如何对象的问题(接口).

从基于消息的角度比从基于类的角度, 更能产生出灵活的应用程序.

直接说"要什么", 而不是亲自去告知"怎么做".



让对象的上下文简单, 这样易于使用, 也方便测试.



`private` `protected` `public` 传达了两层信息: 稳定性和可见性.



Demeter 法则禁止: 将消息通过第二个不同类型的对象转发给第三个对象. (跨对象的链式调用)



## 鸭子类型

OO的设计目的是减少变化的成本. 消息是程序设计的中心, 应该设计严格定义的公共接口.

表现出鸭子行为的就是鸭子.

对象是通过他们的行为定义的. 



多态: 不同对象响应同一消息的能力.



## 继承

继承的核心是一种"消息自动委托"的机制: 当对象接收到它不明白的消息时, 会将这个消息自动转发/委托给第二个对象(未知消息沿着父类层次结构向上委托).

Ruby 的继承是单继承, 一个父类可以有多个子类, 一个子类只允许有一个父类.

nil 是 NilClass 类的实例:

```ruby

nil.nil? # => true
# NilClass 响应 nil? 返回 true

"str".nil? # => false
# 其他对象都继承自 Object, Object 响应 nil? 返回 false
```



在决定使用继承的方式之前, 考虑使用它的成本:

1. 实现成本
2. 一旦不合适修改它的成本

基于成本的考虑会让我们把继承的使用推迟到非用不可的时刻, 这就是最经济和明智的选择.

关于如何实现继承, `全部下放再部分提升` 是个好办法.



使用模板方法提示子类需要实现的方法: `NotImplementedError`  .

```ruby
class Person
  def age
    raise NotImplementedError, "#{self.class}##{__method__}"
  end
end

class DaSha < Person
end

class XiaoMing < Person
  def age
    12
  end
end

puts XiaoMing.new.age
puts DaSha.new.age

=begin
12
Traceback (most recent call last):
        1: from main.rb:17:in `<main>'
main.rb:3:in `age': DaSha#age (NotImplementedError)

=end
```





### 使用模板, 避免子类主动调用super

```ruby
class Person
  attr_reader :age, :name, :gender

  def initialize(args = {})
    @age = args[:age] || my_age
    @name = args[:name] || my_name
  end

  def say
    "Hi, this is #{name}, i'm #{age}." + self_introduction
  end

  protected

  def my_age
    raise NotImplementedError
  end

  def my_name
    "Default Name: #{self.class}"
  end

  def self_introduction
    '害羞'
  end
end

class XiaoMing < Person
  protected

  def my_age
    19
  end
end

class XiaoWang < Person
  protected

  def my_age
    22
  end

  def my_name
    '小王'
  end

  def self_introduction
    '我是一个开朗的人.'
  end
end

puts XiaoMing.new.say
puts XiaoWang.new.say
# Hi, this is Default Name: XiaoMing, i'm 19.害羞
# Hi, this is 小王, i'm 22.我是一个开朗的人.

```



## 用模块共享角色

模块用来抽象各个类之间的公共行为(正交行为).

让对象自己说话, 对行文的响应由对象自己响应.

继承关于"是一个", 模块关于"像一个". 能用模块尽量不用继承. 能用模板方法尽量不用 `super` .

LSP 里氏替换原则, 子类承诺能替换父类. 子类的输入只能和父类一致或者更宽松, 子类的输出只能和父类一致或者更严格. 子类可被用于其父类存在的任何地方.



## 组合对象

继承是特殊化.

当公共行为占绝大多数时, 选继承, 否则选组合.

继承用于"是什么", 组合用于"像什么". 



## 划算的测试

好的设计会以最小的成本保留最大的灵活性.

* 找出错误
* 提供文档
* 推迟设计决定
* 支持抽象
* 暴露设计缺陷

