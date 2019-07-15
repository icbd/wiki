---
layout: post
title:  Ruby Monitor Mixin
date:   2019-04-02
categories: Ruby
---

## 前情回顾

对于多线程抢占资源的情景, 
我们可以用 `ConditionVariable` 来抽象需要锁定的资源, 用 `Mutex` 来抽象 Semaphore .

他们都是 Ruby 语言内置的功能, 在 `Thread` 中:  

`ConditionVariable` 即 `Thread::ConditionVariable` ,

`Mutex` 即 `Thread::Mutex` .


如下, consumer 不停地从 buffer 里取数据, producer 从 STDIN 接收数据输入, 然后通知 consumer 来处理.

```ruby
mutex = Mutex.new
resource = ConditionVariable.new

buffer = []

consumer = Thread.new do
  loop do
    mutex.synchronize do
      # 等待资源释放
      resource.wait(mutex)

      item = buffer.pop
      puts ">>>#{item}"
    end
  end
end


producer = Thread.new do
  loop do
    input = ARGF.gets

    mutex.synchronize do
      buffer.push input
      # 通知资源已经释放
      resource.signal
    end
  end
end

consumer.join
producer.join

=begin
$ ruby condition_variable.rb
1
>>>1
2
>>>2
3
>>>3
=end
```

## 使用 Monitor

`MonitorMixin` 模块 是把 `Metux` 和 `ConditionVariable` 的包装, 注入到对象之后, 可以省去手动创建他们的工作: 

```ruby
require 'monitor'

buffer = []
buffer.extend MonitorMixin
condition = buffer.new_cond

consumer = Thread.new do
  loop do
    buffer.synchronize do
      condition.wait_while { buffer.empty? }

      item = buffer.pop
      puts ">>>#{item}"
    end
  end
end

producer = Thread.new do
  loop do
    input = ARGF.gets

    buffer.synchronize do
      buffer.push input
      # 通知资源已经释放
      condition.signal
    end
  end
end

consumer.join
producer.join

```

当然也可以生成两个 condition : 

```ruby
require 'monitor'

buffer = []
buffer.extend MonitorMixin
condition1 = buffer.new_cond
condition2 = buffer.new_cond

consumer1 = Thread.new do
  loop do
    buffer.synchronize do
      condition1.wait_while { buffer.empty? }

      item = buffer.pop
      puts "1>>>#{item}"
    end
  end
end

consumer2 = Thread.new do
  loop do
    buffer.synchronize do
      condition2.wait_while { buffer.empty? }

      item = buffer.pop
      puts "2>>>#{item}"
    end
  end
end

producer = Thread.new do
  loop do
    input = ARGF.gets

    buffer.synchronize do
      buffer.push input

      if input.include?('to1')
        condition1.signal
      else
        condition2.signal
      end
    end
  end
end

consumer1.join
consumer2.join
producer.join

```
