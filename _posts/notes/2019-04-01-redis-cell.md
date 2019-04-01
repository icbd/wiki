---
layout: post
title:  Redis Cell  
date:   2019-04-01
categories: Redis
---

分布式限流模块, 可以原子性地处理限流操作.

## Install 

该模块是用 Rust 写的, 需要先 `brew install rust`

```text
git clone --depth 1 https://github.com/brandur/redis-cell.git
cd redis-cell
cargo build --release
cd ..
./src/redis-server --port 7777 --loadmodule ./redis-cell/target/release/libredis_cell.dylib

```

```text
./src/redis-cli -p 7777
```

## Command

```text
CL.THROTTLE user123 15 30 60 1
               ▲     ▲  ▲  ▲ ▲
               |     |  |  | └───── 处理1个, 可选项, 默认1个
               |     |  └──┴─────── 30 tokens / 60 seconds, 每60秒处理30个
               |     └───────────── 15 漏斗最大容量
               └─────────────────── key

1) (integer) 0      # 0 允许; 1 拒绝
2) (integer) 16     # 漏斗容量
3) (integer) 15     # 漏斗剩余空间
4) (integer) -1     # 如果被拒绝后的重试时间
5) (integer) 2      # 清空漏斗所需要的时间

```

先填满漏斗, 如果漏斗已满, 新入的请求会被拒绝.

返回的漏斗容量是漏斗容量参数值+1.

## Reference

[https://github.com/brandur/redis-cell](https://github.com/brandur/redis-cell)

[https://en.wikipedia.org/wiki/Generic_cell_rate_algorithm](https://en.wikipedia.org/wiki/Generic_cell_rate_algorithm)

[https://www.jianshu.com/p/1b026b874c40?from=timeline&isappinstalled=0](https://www.jianshu.com/p/1b026b874c40?from=timeline&isappinstalled=0)
