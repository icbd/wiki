---
layout: post
title:  Redis Persistence
date:   2019-04-16
categories: Redis
---

### RDB --  Redis Database

1. Redis fork()

2. 子进程将数据集写入到临时的 `.rdb` 文件

3. 子进程完成 `.rdb` 的写入后, Redis 用 新 RDB 文件替换老旧的 RDB 文件, 删除老旧的 RDB 文件.

`.rdb` 的生成过程中, 默认会使用 LZF 算法对 string 进行压缩 (使用 `rdbcompression yes` 来配置) . 

`fork()` 之后会使用写时复制的特性来避免内存的激增.


RDB 默认开启, 默认配置如下:

> redis.conf

```text
# 每900秒内有1个变动
save 900 1
# 每300秒内有10个变动
save 300 10
# 每60秒内有10000个变动
save 60 10000

# 禁用 RDB
# save ""
```

也可以使用 同步命令:`SAVE`, 异步命令:`BGSAVE` 来触发 RDB 更新.

### AOF -- Append-only File

每接受到一个改变数据集的命令, 就将该命令追加到 AOF 末尾. 

将命令追加到 AOF , 首先会写入系统的buffer中, 通过 `fsync` 命令来将buffer刷到磁盘文件上.  

`fsync` 是同步的耗时IO操作, 可以通过控制 `fsync` 的频次来平衡数据的写入速度和数据的安全性. 

AOF 默认不开启, 默认配置如下:

> redis.conf

```text
appendonly no
appendfilename "appendonly.aof"

# appendfsync always
appendfsync everysec
# appendfsync no
```


#### AOF 重建

1. Redis fork()

2. 子进程扫描已有数据重建新的 AOF 到临时文件

3. 父进程中, 接收到新的改变数据集的命令后: 依旧对老旧的 AOF 进行追加; 再写一份到单独的buffer中 .

4. 子进程重建 AOF 完成后, 将新文件替换旧文件, 把buffer追加到文件末尾.


Redis 默认根据以下规则自动重建 AOF:

> redis.conf

```text
no-appendfsync-on-rewrite no

auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```

可以使用 `BGREWRITEAOF` 命令来触发重建. 

还有一点需要注意, `BGREWRITEAOF` 和 `BGSAVE` 不会同时执行, 因为 生成RDB 和 重建AOF 都会涉及大量 IO 操作, 应该避免他们同时发生.



## References

[http://download.redis.io/redis-stable/redis.conf](http://download.redis.io/redis-stable/redis.conf)

[http://doc.redisfans.com/topic/persistence.html](http://doc.redisfans.com/topic/persistence.html)