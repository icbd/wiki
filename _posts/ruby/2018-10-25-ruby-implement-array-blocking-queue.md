---
layout: post
title:  Semaphore 实现生产者/消费者模式(Ruby)  
date:   2018-10-25
categories: Ruby
---

```ruby

class ArrayBlockingQueueWithSemaphone
  attr_reader :size_limit, :queue

  def initialize(size_limit: 10, queue: [])
    @size_limit = size_limit.to_i

    raise "Please set a right size limit." if @size_limit <= 0

    @queue = queue

    @semaphore = Mutex.new
    @able_to_pop = ConditionVariable.new
    @able_to_push = ConditionVariable.new
  end

  def push(item)
    @semaphore.synchronize do

      while @queue.size >= @size_limit
        @able_to_push.wait(@semaphore)
      end

      @queue.push(item)
      @able_to_pop.broadcast

    end
  end

  def pop
    @semaphore.synchronize do

      while @queue.empty?
        @able_to_pop.wait(@semaphore)
      end

      item = @queue.pop
      @able_to_push.broadcast
      item

    end
  end
end


# DEMO
if __FILE__ == $0
  q = ArrayBlockingQueueWithSemaphone.new(size_limit: 3, queue: [-1, -2])

  threads = []

  producer = Thread.new do
    10.times do |i|
      q.push(i)
      puts "\npush #{i}\t\t\tqueue: #{q.queue}\n"

      sleep(0.05)
    end
  end
  threads << producer

  consumer = Thread.new do
    10.times do
      item = q.pop
      puts "\n\t\tpop #{item}\tqueue: #{q.queue}\n"

      sleep(0.15)
    end
  end
  threads << consumer

  monitor = Thread.new do
    loop do
      puts "\t\t\tqueue: #{q.queue}"
      sleep(0.05)

      # # thread.status
      # false means terminated normally
      # nil means terminated with an exception
      #
      # exit monitor if consumer or producer dead/exception
      unless consumer.status && producer.status
        puts "exit monitor"
        Thread.exit
      end
    end
  end
  threads << monitor

  begin
    threads.each do |thr|
      thr.join
    end
  rescue Exception => e
    threads.each do |thr|
      thr.exit
    end

    exit 0
  end
end

```



## DEMO 输出结果

```text

$ ruby array_blocking_queue_with_semaphore.rb
			queue: [-1, -2]

		pop -2	queue: [-1]

push 0			queue: [-1, 0]
			queue: [-1, 0]

push 1			queue: [-1, 0, 1]
			queue: [-1, 0, 1]

push 2			queue: [-1, 0, 2]

		pop 1	queue: [-1, 0, 2]
			queue: [-1, 0, 2]
			queue: [-1, 0, 2]
			queue: [-1, 0, 2]

		pop 2	queue: [-1, 0]

push 3			queue: [-1, 0, 3]
			queue: [-1, 0, 3]
			queue: [-1, 0, 3]
			queue: [-1, 0, 3]

		pop 3	queue: [-1, 0]

push 4			queue: [-1, 0, 4]
			queue: [-1, 0, 4]
			queue: [-1, 0, 4]
			queue: [-1, 0, 4]

		pop 4	queue: [-1, 0]

push 5			queue: [-1, 0, 5]
			queue: [-1, 0, 5]
			queue: [-1, 0, 5]
			queue: [-1, 0, 5]

push 6			queue: [-1, 0, 6]

		pop 5	queue: [-1, 0]
			queue: [-1, 0, 6]
			queue: [-1, 0, 6]
			queue: [-1, 0, 6]

		pop 6	queue: [-1, 0]

push 7			queue: [-1, 0, 7]
			queue: [-1, 0, 7]
			queue: [-1, 0, 7]
			queue: [-1, 0, 7]

		pop 7	queue: [-1, 0]

push 8			queue: [-1, 0, 8]
			queue: [-1, 0, 8]
			queue: [-1, 0, 8]
			queue: [-1, 0, 8]

		pop 8	queue: [-1, 0]

push 9			queue: [-1, 0, 9]
			queue: [-1, 0, 9]
exit monitor

		pop 9	queue: [-1, 0]
		
```

# Ruby Queue

Ruby 的标准库中自带了线程安全的FIFO的 `Queue` :

```test

push(object)        入队列
pop(non_block=false)        出队列

size        队列长度
empty?      队列是否为空
clear       清空队列
close       关闭队列, 关闭之后不能push可以pop. 已关闭的队列为空之后, pop立即返回nil.
closed?     队列是否关闭
num_waiting     线程等待数

```


```ruby

queue = Queue.new
queue.push "init"

push_thr_1 = Thread.new do
  6.times do |i|
    item = "push-No.#{i}-from-thr1"
    puts item
    queue.push(item)
    sleep 0.3
  end
end

push_thr_2 = Thread.new do
  15.times do |i|
    item = "push-No.#{i}-from-thr2"
    puts item
    queue.push(item)
    sleep 0.2
  end
end


# 当queue为空时, pop 默认会阻塞来等待queue的新元素.
# 该例子中, pop的频率高于push的频率, 等初始的数据pop完之后, 就只能等push完成才能pop一次.
pop_thr = Thread.new do
  (1 + 6 + 15).times do |j|
    item = "pop-No.#{j}"
    puts "pop\t\t" + queue.pop
    sleep 0.1
  end
end

push_thr_1.join
push_thr_2.join
pop_thr.join

puts "main exits."

=begin
push-No.0-from-thr1
pop		init
push-No.0-from-thr2
pop		push-No.0-from-thr1
push-No.1-from-thr2
pop		push-No.0-from-thr2
push-No.1-from-thr1
pop		push-No.1-from-thr2
push-No.2-from-thr2
pop		push-No.1-from-thr1
pop		push-No.2-from-thr2
push-No.2-from-thr1
push-No.3-from-thr2
pop		push-No.2-from-thr1
pop		push-No.3-from-thr2
push-No.4-from-thr2
pop		push-No.4-from-thr2
push-No.3-from-thr1
pop		push-No.3-from-thr1
push-No.5-from-thr2
pop		push-No.5-from-thr2
push-No.4-from-thr1
pop		push-No.4-from-thr1
push-No.6-from-thr2
pop		push-No.6-from-thr2
push-No.7-from-thr2
pop		push-No.7-from-thr2
push-No.5-from-thr1
pop		push-No.5-from-thr1
push-No.8-from-thr2
pop		push-No.8-from-thr2
push-No.9-from-thr2
pop		push-No.9-from-thr2
push-No.10-from-thr2
pop		push-No.10-from-thr2
push-No.11-from-thr2
pop		push-No.11-from-thr2
push-No.12-from-thr2
pop		push-No.12-from-thr2
push-No.13-from-thr2
pop		push-No.13-from-thr2
push-No.14-from-thr2
pop		push-No.14-from-thr2
main exits.
=end

``` 