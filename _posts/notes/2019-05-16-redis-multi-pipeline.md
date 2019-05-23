---
layout: post
title:  Redis Pipeline and Multi
date:   2019-05-16
categories: Redis
---

这里结合 Ruby 的 Redis Gem 来解释两者的异同.

## pipelined 管道

```ruby
require 'redis'
require 'pry'
redis = Redis.new
redis.flushdb

result = redis.pipelined do
  @r1 = redis.set('k1', 'v1')
  p @r1
  # <Redis::Future [:set, "k1", "v1"]>
  @r2 = redis.get('k1')
  p @r2
  # <Redis::Future [:get, "k1"]>
  @r3 = redis.set('k2', 'v2')
  p @r3
  # <Redis::Future [:set, "k2", "v2"]>
  @r4 = redis.get('k2')
  p @r4
  # <Redis::Future [:get, "k2"]>
  begin
    @r4.value
  rescue Redis::FutureNotReady => e
    p e
    # #<Redis::FutureNotReady: Value will be available once the pipeline executes.>
  end
end
p result
["OK", "v1", "OK", "v2"]
p @r1.value, @r2.value, @r3.value, @r4.value
# "OK"
# "v1"
# "OK"
# "v2"


```

pipelined 很好用也很好理解, 就是把多个命令打包, 由客户端一起发出, 然后一起收到各个命令的结果.

Ruby 的 Redis Gem 要求把命令放到 pipelined 的 block 中.

在 block 结束之前, 我们都拿不到具体命令的返回值, 而是得到一个 `Redis::Future` 对象.

如果在该 block 内强制读取 value, 会抛出 `Redis::FutureNotReady` 的异常.

而在 block 外, 可以通过 value 来获取 `Redis::Future` 的返回值, 或者去 pipelined 返回的数组里去取对应的值.

关于实现原理,

普通的多条读写是: 

```text
写-读(耗时IO) + 写-读(耗时IO) + 写-读(耗时IO)
```

pipelined是:

```text
写-写-写 + 读(耗时IO)-读-读
```

需要强调的一点是, pipelined 是客户端提供的功能, 通过改变读写顺序来减少读操作的耗时.

```ruby
require 'redis'
redis = Redis.new
redis.flushdb

begin
  result = redis.pipelined do
    @r1 = redis.set('k1', 'v1')
    @r2 = redis.incr('k1')
    @r3 = redis.set('k2', 'v2')
    @r4 = redis.get('k2')
  end
rescue => e
  p e
    # #<Redis::CommandError: ERR value is not an integer or out of range>
ensure
  p redis.get('k1')
  # "v1"
  p redis.get('k2')
  # "v2"
end
p result
# nil

begin
  p @r1.value, @r2.value, @r3.value, @r4.value
rescue Redis::FutureNotReady => e
  p e
  # #<Redis::FutureNotReady: Value will be available once the pipeline executes.>
end

```

当 pipelined 中的某条操作抛出异常时, 不会打断后续的操作. 也就是说, 对 'v1' 和 'v2' 的set操作都已经生效了.

区别是 pipelined 会抛出相关的异常, 而且返回nil, `Redis::Future` 的 value 不再可用(包括发生异常以前的命令). 


# multi 事务

这里将 Redis 的 multi 翻译为 `事务`, 但是它只保证了事务的原子性, 而且不支持回滚.

```ruby
require 'redis'

redis = Redis.new
redis2 = Redis.new

p redis.multi
# "OK"
p redis.set('k1', 'v1')
# "QUEUED"
p redis.get('k1')
# "QUEUED"
p redis.set('k2', 'v2')
# "QUEUED"
p redis.get('k2')
# "QUEUED"

p '---'
p redis2.get('k1')
# nil
p '---'

p redis.exec
# ["OK", "v1", "OK", "v2"]
```

以上是对命令行multi的直接映射, 以一条 `multi` 命令开启事务. 

之后的每一条命令都单独发给Server, Server收到后加入该事务的待执行队列, Server只会返回客户端 `QUEUED` 这个字符串来表示入队成功.

当Server收到 `exec` 命令时, 就原子性地执行这一批命令; 当收到 `discard` 命令, 就丢掉之前收集的命令, 放弃执行.


 
```ruby
require 'redis'

redis = Redis.new

p redis.multi
# "OK"
p redis.set('k1', 'v1')
# "QUEUED"
p redis.get('k1')
# "QUEUED"
p redis.incr('k1')
# "QUEUED"
p redis.set('k2', 'v2')
# "QUEUED"
p redis.get('k2')
# "QUEUED"
p redis.exec
# ["OK", "v1", #<Redis::CommandError: ERR value is not an integer or out of range>, "OK", "v2"]

```

其中一个命令异常时, 后续的命令也继续执行, `exec` 返回数组, 包含各个命令的执行结果. 


```ruby
require 'redis'

redis = Redis.new

begin
  result = redis.multi do
    p redis.set('k1', 'v1')
    # <Redis::Future [:set, "k1", "v1"]>
    p redis.get('k1')
    # <Redis::Future [:get, "k1"]>
    p redis.incr('k1')
    # <Redis::Future [:incr, "k1"]>
    p redis.set('k2', 'v2')
    # <Redis::Future [:set, "k2", "v2"]>
    p redis.get('k2')
    # <Redis::Future [:get, "k2"]>
  end
rescue Redis::CommandError => e
  p redis.get('k1')
  # "v1"
  p redis.get('k2')
    # "v2"
ensure
  p result
  # nil
end
```

## WATCH and UNWATCH

`watch` 命令跟 `multi` 配合使用, 实现对某个key的乐观锁.

```ruby
require 'redis'

redis = Redis.new

key = :my_key
redis.set key, 100
redis.watch key

result = redis.multi do
  redis.incr key
  redis.incr key
end

p result
p redis.get key
```

outputs:

```text
[101, 102]
"102"

```

```ruby
require 'redis'

redis = Redis.new

key = :my_key
redis.set key, 100
redis.watch key
redis.incr key

result = redis.multi do
  redis.incr key
  redis.incr key
end

p result
p redis.get key
```

outputs:

```text
nil
"101"
```

他们的区别是第二个例子里, watch 和 multi 之间, 我们对 watch 的 key 做了值的修改.

如此一来, multi 就会失败.

我们可以手动 `unwatch`, `unwatch` 只能将所有的 `watch` 都清掉, 不能指定单独的key.

还有就是, 如果我们调用了 multi 的 exec 和 discard 的之后, 就不需要手动 `unwatch` .

# watch 跨客户端的情况

在同一个client中使用 watch 和 multi :

```ruby
require 'redis'

redis = Redis.new
redis1 = Redis.new
redis2 = Redis.new

redis.set 'k', 100

redis1.watch 'k'

redis.incr 'k'

result = redis1.multi do
  redis1.incr 'k'
  redis1.incr 'k'
end

p result
p redis.get 'k'

# output:
# nil
# "101"
```

watch 和 multi 在不同的客户端:

```ruby
require 'redis'

redis = Redis.new
redis1 = Redis.new
redis2 = Redis.new

redis.set 'k', 100

redis2.watch 'k'

redis.incr 'k'

result = redis1.multi do
  redis1.incr 'k'
  redis1.incr 'k'
end

p result
p redis.get 'k'

# output:
# [102, 103]
# "103"
```



## Reference

[https://redis.io/commands/unwatch](https://redis.io/commands/unwatch)

[https://redis.io/commands/multi](https://redis.io/commands/multi)

[https://www.jianshu.com/p/361cb9cd13d5](https://www.jianshu.com/p/361cb9cd13d5)

