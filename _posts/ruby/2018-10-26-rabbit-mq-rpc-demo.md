---
layout: post
title:  借由RabbitMQ实现RPC调用的DEMO
date:   2018-10-26
categories: Ruby
---


[!https://www.rabbitmq.com/img/tutorials/python-six.png](图解)


## server.rb

```ruby

require 'bunny'

module RabbitMQRPC
  class Server
    def initialize
      @mq_conn = Bunny.new
      @mq_conn.start
      @mq_channel = @mq_conn.create_channel
    end

    def start(enter_queue_name)
      # 被server监听的接收队列, 使用具名队列方式直接指定队列名称
      @mq_exchange = @mq_channel.default_exchange
      @mq_queue = @mq_channel.queue(enter_queue_name)

      @mq_queue.subscribe(block: true) do |_delivery, _properties, body|
        result = time_consuming_task(_delivery, _properties, body)

        # 根据 _properties.reply_to 标记不同的客户端
        # 根据 _properties.correlation_id 标记不同的请求
        @mq_exchange.publish(result.to_s,
                             routing_key: _properties.reply_to,
                             correlation_id: _properties.correlation_id,
        )

      end

    end

    def call(a)

    end

    def close
      @mq_channel.close if @mq_channel
      @mq_conn.close if @mq_conn
    end

    def time_consuming_task(_delivery, _properties, body)
      raise NotImplementedError.new("#{self.class.name}#time_consuming_task")
    end
  end
end


# DEMO
if __FILE__ == $0
  class Server < RabbitMQRPC::Server
    def time_consuming_task(_delivery, _properties, body)
      time_consuming = rand(0.1..0.9).round(3)
      sleep(time_consuming)

      "#{_properties.reply_to}\t\t#{_properties.correlation_id}\t\t#{body} time_consuming: #{time_consuming} s"
    end
  end


  begin
    server = Server.new
    server.start("enter_queue_name_for_demo")
  rescue Interrupt => _
    server.close
  end

end

```


## client.rb

```ruby

require 'bunny'
require 'SecureRandom'

module RabbitMQRPC
  class Client

    attr_accessor :response, :request_id

    def initialize(enter_queue_name)
      @enter_queue_name = enter_queue_name

      @mq_conn = Bunny.new
      @mq_conn.start
      @mq_channel = @mq_conn.create_channel

      @mq_exchange = @mq_channel.default_exchange
      # MQ自动分配队列, 用来接收回复
      @reply_queue = @mq_channel.queue("", exclusive: true)

      @semaphore = Mutex.new
      @resource = ConditionVariable.new

      # 订阅回复, 收到回复后通知原始请求
      @reply_queue.subscribe do |_delivery, _property, body|

        # 确保请求与响应一一对应
        if _property[:correlation_id] == @request_id
          @response = body

          @semaphore.synchronize do
            @resource.signal
          end
        end

      end
    end

    def call(task_param)
      @request_id = "request_id:#{SecureRandom.uuid}"

      @mq_exchange.publish(task_param,
                           routing_key: @enter_queue_name,
                           reply_to: @reply_queue.name,
                           correlation_id: @request_id,
      )

      # 阻塞, 直到对应的响应发信号. 最多等2秒
      @semaphore.synchronize do
        @resource.wait(@semaphore, 2)

        response = @response
        @response = nil

        response
      end
    end

    def close
      @mq_channel.close
      @mq_conn.close
    end
  end
end


# DEMO
if __FILE__ == $0
  client = RabbitMQRPC::Client.new("enter_queue_name_for_demo")
  30.times do |i|
    response = client.call("client_call_#{i}") || "timeout"

    puts response
  end
  client.close
end


```