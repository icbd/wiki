---
layout: post
title:  Redis module RedisBloom
date:   2019-04-01
categories: Redis
---

## Install

布隆过滤器应该不陌生了, 之前使用的版本是 Gem 包封装 BitMap 来实现的, 效率上存在一些问题. 

Redis 从4.0开始支持用模块来扩展Redis的功能, 今天来试试 Redis 模块中对 Bloom 的支持: [RedisBloom](https://github.com/RedisLabsModules/redisbloom) .

免安装的方法是使用现成的 Docker 镜像:

```bash
docker run -p 6379:6379 --name redis-redisbloom redislabs/rebloom:latest
docker exec -it redis-redisbloom bash
# redis-cli
# 127.0.0.1:6379> 
```

由于编译 Redis 实在是很方便, 这里选择用源码编译:

1) 下载&编译 redis 本身

```bash
git clone --branch 5.0 --depth 1 https://github.com/antirez/redis.git
cd redis
make
```

2) 下载&编译 RedisBloom 模块

```bash
git clone --depth 1 https://github.com/RedisLabsModules/redisbloom.git
cd redisbloom
make
```

这时会得到 `./redisbloom/rebloom.so`, 启动 redis-server 的时候加载该 `.so` 文件:

```bash
cd ..
./src/redis-server --port 7777 --loadmodule ./redisbloom/rebloom.so
```

```bash
./src/redis-cli -p 7777
```

## Bloom Filter

该实现的 Bloom 算法默认错误率为 0.01 , 初始容量为 100 .
        
启动 redis-server 的时候, 可以传入参数来指定这两个值:

```bash
./src/redis-server --port 7777 --loadmodule ./redisbloom/rebloom.so INITIAL_SIZE 400 ERROR_RATE 0.004
```

正因为有如上的默认参数, 我们可以开箱即用地使用 `BF.ADD` 命令来对一个key添加元素标记. 

但是考虑到具体的使用场景需要的容错率和元素容量不同, 我们最好用 `BF.RESERVE` 来指定一个Bloom的数据结构.


初始化一个容错率为 0.1% , 设计容量为 1000000 的Bloom:
 
```bash
BF.RESERVE sample_key 0.001 1000000
```

占用情况如下: 

```bash
127.0.0.1:7777> DEBUG OBJECT sample_key
Value at:0x7f887a500650 refcount:1 encoding:raw serializedlength:23898 lru:10598970 lru_seconds_idle:426
```

serializedlength  的单位是 byte .

Bloom 并不像String或者Hash那样可以自动扩展, 如果实际的元素数量超出计划值, 就要拿原始数据重建Bloom.

具体参数选择可以参考这个布隆过滤器计算器: [https://krisives.github.io/bloom-calculator/](https://krisives.github.io/bloom-calculator/) .

添加元素:

```text
127.0.0.1:7777> BF.ADD sample_key k1
(integer) 1
127.0.0.1:7777> BF.ADD sample_key k2
(integer) 1
127.0.0.1:7777> BF.ADD sample_key k3
(integer) 1
127.0.0.1:7777> BF.ADD sample_key k3
(integer) 0

``` 

一次添加多个:

```text
127.0.0.1:7777> BF.MADD sample_key k4 k5 k6
1) (integer) 1
2) (integer) 1
3) (integer) 1
```

查询是否存在:

```text
127.0.0.1:7777> BF.EXISTS sample_key k3
(integer) 1
127.0.0.1:7777> BF.EXISTS sample_key kx
(integer) 0
```

一次性查询多个是否存在:

```text
127.0.0.1:7777> BF.MEXISTS sample_key k1 k3 kx
1) (integer) 1
2) (integer) 1
3) (integer) 0
```

插入元素, 结合RESERVE和ADD功能:

添加一个或多个:
```text
BF.INSERT sample_key ITEMS k1 k100
1) (integer) 0
2) (integer) 1
```

如果 key 不存在, 就使用参数中的 CAPACITY 和 ERROR 初始化一个新的 Bloom: 

```text
127.0.0.1:7777> BF.INSERT new_sample_key CAPACITY 1000 ITEMS k1 k100
1) (integer) 1
2) (integer) 1
127.0.0.1:7777> del new_sample_key
(integer) 1
127.0.0.1:7777> BF.INSERT new_sample_key CAPACITY 1000 ERROR 0.01 ITEMS k1 k100
1) (integer) 1
2) (integer) 1
```

只允许使用已存在的key, 不许创建新的key:

```text
127.0.0.1:7777> BF.INSERT new_sample_key CAPACITY 1000 ERROR 0.01 NOCREATE ITEMS k1 k100
1) (integer) 0
2) (integer) 0
127.0.0.1:7777> BF.INSERT new_new_sample_key CAPACITY 1000 ERROR 0.01 NOCREATE ITEMS k1 k100
(error) ERR not found
127.0.0.1:7777> BF.INSERT new_new_sample_key CAPACITY 1000 NOCREATE ITEMS k1 k100
(error) ERR not found
127.0.0.1:7777> BF.INSERT new_new_sample_key NOCREATE ITEMS k1 k100
(error) ERR not found
```


还有两个处理大Bloom的命令: `BF.SCANDUMP` 和 `BF.LOADCHUNK` .


## Cuckoo Filter

在实现原理上, Cuckoo Filter 使用了两个Hash: HashA 和 HashB, 和两份数据存储: 存储A 和 存储B.

将HashA的结果记录在存储A上, 将HashB的结果记录在存储B上. 

如果新加入的k2的hashA跟之前的k1的HashA结果碰撞了, 就让k2占据k1在存储A上的位置, 让k1使用存储B(通过HashB计算得出).


Cuckoo Filter的默认误报率在 3% 左右.

Cuckoo Filter 没有 Bloom Filter 的插入效率高. 

当误报率在 3% 以内时, Cuckoo Filter 的空间性能更好.

Cuckoo Filter 支持删除操作, 但是删除操作会提升误报的可能性, 特别是元素数量逼近设计容量的时候.

Redis 提供 `CF` 命令组来使用 Cuckoo Filter.


## Reference

[https://github.com/RedisLabsModules/redisbloom](https://github.com/RedisLabsModules/redisbloom)

[https://oss.redislabs.com/redisbloom/Bloom_Commands/](https://oss.redislabs.com/redisbloom/Bloom_Commands/)

[https://oss.redislabs.com/redisbloom/Cuckoo_Commands/](https://oss.redislabs.com/redisbloom/Cuckoo_Commands/)

[https://krisives.github.io/bloom-calculator/](https://krisives.github.io/bloom-calculator/)

[https://coolshell.cn/articles/17225.html](https://coolshell.cn/articles/17225.html)

[https://www.cnblogs.com/chuxiuhong/p/8215719.html](https://www.cnblogs.com/chuxiuhong/p/8215719.html)

[https://www.youtube.com/watch?v=-Ubo5GUluGQ](https://www.youtube.com/watch?v=-Ubo5GUluGQ)

[https://www.youtube.com/watch?v=tiYcWJPtcs4](https://www.youtube.com/watch?v=tiYcWJPtcs4)