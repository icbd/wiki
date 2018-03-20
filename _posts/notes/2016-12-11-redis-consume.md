---
layout: post
title:  Redis命令耗时测试
date:   2016-12-11
categories: Redis
---

```
Array
(
    [redis_version] => 3.2.5
    [redis_mode] => standalone
    [os] => Darwin 16.1.0 x86_64
    [arch_bits] => 64
    [multiplexing_api] => kqueue
    [gcc_version] => 4.2.1
    [total_system_memory_human] => 8.00G

    [used_memory_human] => 1014.19K
```

## 粗略结果,仅可在数量级上参考

Redis String    10万不同key的set操作,耗时5秒,占用8.6M内存.

Redis Set       10万相同key的add操作,耗时5秒,占用7M内存.

Redis List      10万相同key的add操作,耗时5秒,占用7M内存.

Redis zSet      10万相同key的zadd操作,耗时6秒,占用12M内存.

Redis Hash      10万相同key的hset操作,耗时6秒,占用10M内存.

Mysql insert    10万insert操作,耗时10秒.


## 使用Redis自带的性能测试
> cbd@Baodong-MBP:~$ redis-benchmark -c 1 -q
> -c 用1个client测试, -q只显示结果摘要.

```
PING_INLINE: 27457.44 requests per second
PING_BULK: 28604.12 requests per second
SET: 27563.40 requests per second
GET: 27762.35 requests per second
INCR: 28727.38 requests per second
LPUSH: 26990.55 requests per second
RPUSH: 27367.27 requests per second
LPOP: 27247.96 requests per second
RPOP: 26082.42 requests per second
SADD: 27563.40 requests per second
SPOP: 28129.39 requests per second
LPUSH (needed to benchmark LRANGE): 26932.40 requests per second
LRANGE_100 (first 100 elements): 14645.58 requests per second
LRANGE_300 (first 300 elements): 7452.68 requests per second
LRANGE_500 (first 450 elements): 5395.20 requests per second
LRANGE_600 (first 600 elements): 4073.82 requests per second
MSET (10 keys): 24912.80 requests per second
```

> cbd@Baodong-MBP:~$ redis-benchmark -c 100 -q

```
PING_INLINE: 62500.00 requests per second
PING_BULK: 54171.18 requests per second
SET: 55432.37 requests per second
GET: 58105.75 requests per second
INCR: 58377.11 requests per second
LPUSH: 51440.33 requests per second
RPUSH: 54525.63 requests per second
LPOP: 55126.79 requests per second
RPOP: 40950.04 requests per second
SADD: 43308.79 requests per second
SPOP: 55187.64 requests per second
LPUSH (needed to benchmark LRANGE): 48146.37 requests per second
LRANGE_100 (first 100 elements): 16406.89 requests per second
LRANGE_300 (first 300 elements): 8017.32 requests per second
LRANGE_500 (first 450 elements): 6218.91 requests per second
LRANGE_600 (first 600 elements): 4853.19 requests per second
MSET (10 keys): 52383.45 requests per second
```