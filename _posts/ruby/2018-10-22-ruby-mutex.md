---
layout: post
title:  Ruby Mutex  
date:   2018-10-22
categories: Ruby
---

Mutex 实现了简单的 semaphone , 可以用来在多线程之间并发访问共享数据.


## 未使用Mutex的多线程执行

```ruby

a = Thread.new {
  5.times do
    print "a1"
    sleep 0.1
    print "a2\n"
  end
}

b = Thread.new {
  5.times do
    print "b1"
    sleep 0.15
    print "b2\n"
  end
}

a.join
b.join

print "main."

=begin
b1a1a2
a1b2
b1a2
a1b2
b1a2
a1a2
a1b2
b1a2
b2
b1b2
=end

```

## 使用Mutex的多线程执行

```ruby

semaphore = Mutex.new

a = Thread.new {
  semaphore.synchronize {
    5.times do
      print "a1"
      sleep 0.1
      print "a2\n"
    end
  }
}

b = Thread.new {
  # 等效写法
  semaphore.lock
  begin
  5.times do
        print "b1"
        sleep 0.15
        print "b2\n"
      end
  ensure
  semaphore.unlock
  end
}

a.join
b.join

print "main."

=begin
b1b2
b1b2
b1b2
b1b2
b1b2
a1a2
a1a2
a1a2
a1a2
a1a2
=end

```