---
layout: post
title:  RabbitMQ Basic usage
date:   2019-08-20
categories: RabbitMQ
---

## Hello World

最基本用法, 用默认 Exchange 向 具名 Queue `queue_name` 里发布消息. 
如果没有消费者, 消息缓存在 Queue 中, 待消费者上线之后再来取.

这种情况下, 消费者会一直监听该 Queue ,消费者并不会考虑自己的处理能力, 但凡有新的消息就会拉下来处理, 来不及处理的话就在客户端堆积.
如果存在处理不过来的消息, 消费者又crash了, 消息就丢了. 

publisher:
```ruby
require 'bunny'

url = "amqp://guest:guest@127.0.0.1:5672"
connection = Bunny.new(url).tap(&:start)

channel = connection.create_channel
channel.default_exchange.publish('Message Body', routing_key: 'queue_name')
connection.close

```

listener:
```ruby
require 'bunny'

url = "amqp://guest:guest@127.0.0.1:5672"
connection = Bunny.new(url).tap(&:start)

channel = connection.create_channel
queue = channel.queue('queue_name')

begin
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    p body
    sleep 5
  end
rescue => _e
  connection.close
  exit(0)
end

```

## Work Queue (Task Queue)

如果我们启动多个消费者, 消息会以 `Round-robin` 模式被处理 -- 按顺序轮流发给各个消费者, 负载平摊到每个消费者上.


默认情况下, RabbitMQ 把发给消费者的消息自动删除. 
如果消息是耗时的易错的, 我们可以设置为手动处理, 先接收消息处理消息, 等处理完成之后再发 `ack`.

当 channel 关闭 / connection 关闭 / TCP 连接断开, 会被认为是该消费者下线, RabbitMQ 将把这个消费者还没有 ack 的消息重新入 Queue , 
再发给其他在线的消费者.

选择手动处理 ack 后, 有一个很重要的特性需要知道, RabbitMQ 没有处理超时, 消费者没有发 ack 就会被认为一直在处理这个消息, 并不会超时自动结束.

也就是说, 如果一个消费者忘记发 ack 后, 他就不会再被派发任何新消息了. 
更可拍的是, 重启消费者也不能解决这个问题, 连接断开后, 消息会重新回到 Queue, 然后再分给一个可用消费者, 它也会遇到相同的问题.
所以无论业务逻辑是成功还是失败, 都要发送 ack 来告知 RabbitMQ 你处理完这个消息了, 不然这个消费者就废掉了.

ack 是 channel 级别的.

Queue 的名字不能重复, 已存在的 Queue 不能直接修改它的配置.

默认情况下, RabbitQM 的 queues 和 messages 会在 RabbitMQ 重启之后自动清除, 可以手动开启持久化设置.

对 Queue 使用 `durable` 来限定 Queue 是持久的, 即使 RabbitMQ 重启 (生产者和消费者都需要在创建Queue的时候设置这个选项);

对 message publish 使用 `persistent` 来命令消息是落盘的 (只需要生产者配置) .


默认情况下, RabbitMQ 总是会把第n个消息发给第n个的消费者, 不管该消费者是不是忙碌, 也不管其他消费者是不是空闲.


我们可以在 Channel 上设置 `prefetch` 来限定, 该消费者最多可以同时处理几个消息. 
如果 `prefetch` 设为 1, 如果一个消费者在忙, 那就不会再发给他一个新消息, 去发给下一个空闲的消费者.


publisher:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
message = ARGV.join(' ')

channel.default_exchange.publish(message, routing_key: 'task_queue', durable: true, persistent: true)
puts "published: #{message}"
conn.close

```

listener:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
channel.prefetch(1)
queue = channel.queue('task_queue', durable: true)

begin
  queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
    p body
    sleep 5 if body.include?('sleep')
    puts '[DONE]'
    channel.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close
end

```

## Publish and Subscribe (fanout exchange)

生产者生产消息; 队列存贮消息; 消费者消费消息.

生产者不会直接发消息给消费者.

生产者把消息给 Exchange, Exchange 把消息给 Queue.

Exchange 分下面几个类型: direct, topic, headers, fanout.


新建一个独占的 Queue, 名字由RabbitMQ随机生成: `queue = channel.queue('', exclusive: true)` . 
当该连接断开的时候, Queue 自动回收, 因为他是被独占的.

对于一个fanout的 Exchange, 如果没人听, 也就是没有 Queue 绑定到这个 Exchange上, 那消息就直接丢弃掉了.

生成者需要确定好 Exchange 的模式和名字, 就往里面发消息就好了;

消费者需要知道 Exchange 的名字, 然后自己创建一个queue 来跟该 Exchange 绑定, 这样就能听到该 Exchange 的消息了.

publisher:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.fanout('logs_exchange')
message = ARGV.join(' ')
exchange.publish(message)
puts "published: #{message}"
conn.close

```

listener:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.fanout('logs_exchange')
queue = channel.queue('', exclusive: true)
queue.bind(exchange)

puts 'Waiting for logs:'
begin
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts "MSG: #{body}"
  end
rescue
  channel.close
  conn.close
end
```

## Routing (direct exchange)

`fanout` 是一对多无差别的广播; `direct` 可以向不同的 `routing_key` 广播, 消费者自己选择收听哪几个 `routing_key` 下的消息.

消息选择收听某个 `routing_key`, 就需要 `queue.bind(exchange, routing_key: routing_key)` .

这样有一个限制就是, `routing_key` 只能是确定的字符串.

publisher:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.direct('logs_direct_exchange')
routing_key = ARGV[0] # level
message = ARGV[1..-1].join(' ')
exchange.publish(message, routing_key: routing_key)
puts "routing_key:#{routing_key}, message:#{message}"
conn.close
```

listener:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.direct('logs_direct_exchange')
queue = channel.queue('', exclusive: true)

ARGV.each do |routing_key|
  queue.bind(exchange, routing_key: routing_key)
end

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts "routing_key:#{delivery_info.routing_key}, message:#{body}"
  end
rescue
  channel.close
  conn.close

  exit 0
end

```

## Topic (topic exchange)

```text
* 至少一个
# 零个或多个
```

包含 hi 的任意 routing_key: `"#.hi.#"` .
直接用 `hi` 就要求生产者只能用 `hi`.

publisher:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.topic('logs_topic_exchange')

routing_key = ARGV[0]
message = ARGV[1..-1].join(' ')
exchange.publish(message, routing_key: routing_key)
puts "routing_key:#{routing_key}, message:#{message}"
conn.close

```

listener:
```ruby
require 'bunny'

conn = Bunny.new.tap(&:start)
channel = conn.create_channel
exchange = channel.topic('logs_topic_exchange')
queue = channel.queue('', exclusive: true)

ARGV.each do |routing_key|
  p "bind routing_key:#{routing_key}"
  queue.bind(exchange, routing_key: routing_key)
end

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts "routing_key:#{delivery_info.routing_key}, message:#{body}"
  end
rescue
  channel.close
  conn.close

  exit 0
end

```