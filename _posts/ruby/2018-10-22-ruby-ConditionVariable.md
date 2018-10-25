---
layout: post
title:  Ruby ConditionVariable  
date:   2018-10-22
categories: Ruby
---

ConditionVariable 对象增强了 Mutex. 使用 条件变量 , 可以在 "锁区"(in the middle of a critical section) 挂起直到资源可用.

```ruby
mutex = Mutex.new
resource = ConditionVariable.new

c1 = Thread.new {
  mutex.synchronize {
    puts "c1 start"
    resource.wait(mutex) # 等待 resource 到位才能继续, 否则阻塞
    puts "c1 end"
  }
}

sleep 0.5 # 确保线程启动顺序

c2 = Thread.new {
  mutex.synchronize {
    puts "c2 start"
    resource.wait(mutex, 10) # 最多阻塞 10s, 即使没有信号通知也返回. (超时不影响锁的竞争)
    puts "c2 end"
  }
}

sleep 0.5 # 确保线程启动顺序

p1 = Thread.new {
  mutex.synchronize {
    puts "p1 start; p1 need sleep:"
    3.times do
      print "."
      sleep 1
    end
    resource.signal # 给等待的resource资源的第一个线程(c1)发信号, 通知资源其到位了: 将其唤醒
    # resource.broadcast # 给等待的resource资源的所有线程(c1和c2)广播信号: 将他们唤醒
    puts "p1 end"
  }
}

c1.join
c2.join
p1.join

puts "main end"


=begin

c1 start
c2 start
p1 start; p1 need sleep:
...p1 end
c1 end 
c2 end # 这里等了大约7秒
main end

=end
```

## wait

释放 Mutex 锁, 并等待资源就位; 当唤醒线程的时候重新获得锁.

如果设置了超时, 则超时后方法返回, 即使没有其他线程通知它资源就位(在获得mutex锁的前提下).


## 特别注意

如果等待信号的线程(比如c1或c2)join时并没有其他活跃线程, 会报致命死锁: 

`No live threads left. Deadlock? (fatal)`