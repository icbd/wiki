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
