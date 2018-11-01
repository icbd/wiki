---
layout: post
title:  Ruby线程安全与GIL
date:   2018-11-01
categories: Ruby thread-safe
---

## 什么是线程安全?

很难讲清楚什么是线程安全. 那么线程不安全会怎么样呢?

如果线程不安全, 那么在多线程条件下, 你的数据将很可能遭到错误.

这里的数据并非数据库的数据, 而是在你脚本中的数据结构(保存在内存中).

## 例子

> demo code 1

```ruby
counter = 0
10.times.map do
  Thread.new do
    tmp = counter + 1
    counter = tmp
  end
end.each(&:join)
puts "\ncounter:#{counter}"
=begin

counter:10
=end
```

counter 是个计数器, 现在开10个线程, 分别在每个线程中对counter做加一计算.

看起来结果很正常, 并没有什么异常. 

如果我们修改一下代码, 在 `counter = tmp` 之前打印一个 `*` :

> demo code 2

```ruby

counter = 0
10.times.map do
  Thread.new do
    tmp = counter + 1
    print "*"
    counter = tmp
  end
end.each(&:join)
puts "\ncounter:#{counter}"
=begin
**********
counter:6
=end

```

结果显示, 打印了十个 `*` 但是计数器只加到了6, 数据错了.

这是为什么呢?

## 先解释为什么counter会出错

我们启动了10个线程之后, 各个线程就各自工作了, 我们并不能参与他们, 线程的管理都由调度器完成. 

调度器具体怎么安排每个线程的执行顺序和执行时间, 我们并不能影响也无从知道其中的细节. 

比如说此时counter为3, 那么就有可能发生在线程A刚打印完 `*` 的时候被暂停下来(此时tmp为4), CPU交给线程B继续使用. 

此时counter还是3, 线程B将counter加一之后, counter变成4. 线程B完成了自己的任务后就退出了. 这时调度器将CPU又交给线程A使用, 在 `counter = tmp` 处恢复, tmp 之前的值为4, counter 被赋值为4. 如此一来, 经过了两个线程的计算, counter 只累加了1, 很明显是出错了.

这就是典型的多线程竞争同一个资源(counter)时, 线程不安全出错的例子.

## 再解释为什么一开始没有错

`demo code 2` 比 `demo code 1` 多了一句 `print "*"`, 为什么加了这句话就让错误暴露了呢?

这里的原因就要涉及到大名鼎鼎的GIL.

GIL 全称 Global Interpreter Lock, 是MRI的一个 "feature" .

GIL 阻止Ruby代码并行运行, 同一个Ruby进程中, 有且只有一个GIL锁, Ruby代码只有获得这把锁之后才能运行, 也就是说同一个时刻, 只有一个Ruby线程在运行. 

需要特别解释的是 GIL 阻止代码并行运行, 而不是并发运行, 单核CPU单进程也可以并发运行多线程的程序(时分复用).

还有一点需要说明" IO阻塞的时候不运行Ruby代码, 也就是说GIL不会阻塞IO. 典型的IO包括网络IO, 磁盘IO, sleep, 各种打印.

`print` 就是一种IO Block. 

GIL 会趁着一个线程IO阻塞的时候赶忙切换另一个线程来使用CPU, 以提高CPU的使用效率; 
调度器也会在计算密集的时候有意减少线程切换, 以减少线程调度带来的不必要开销.

这就解释了为什么 `demo code 1` 很少出错, `demo code 2` 几乎总是出错的原因了:)

小结, 对于 IO-Bound 的程序, 可以多开几个线程来减少IO堵塞的时间浪费, 对于 CPU-Bound 的程序, 多线程只会让调度器白下力做无用功, 因为GIL阻止了并行执行 ~~

## 解决竞争条件

对于上面线程不安全的demo, 由资源竞争而起, 那么只要解决了counter的竞争就可以写出线程安全的代码了:

```ruby

semapore = Mutex.new

counter = 0
10.times.map do
  Thread.new do
    semapore.synchronize do
      tmp = counter + 1
      print "*"
      counter = tmp
    end
  end
end.each(&:join)
puts "\ncounter:#{counter}"
=begin
**********
counter:10
=end

```