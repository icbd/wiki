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