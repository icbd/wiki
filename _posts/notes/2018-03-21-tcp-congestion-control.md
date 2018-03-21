---
layout: post
title:  TCP 拥塞控制小结
date:   2018-03-21
categories: TCPIP
---

# TCP 拥塞控制

拥塞的条件: 对资源的需求大于可用资源.

拥塞控制的目的: 防止过多的数据流入网络, 以免过载.

拥塞控制的前提: 网络能够承受现有的网络负荷.


拥塞控制是全局性的过程, 流量控制是端到端的.


## 慢开始和拥塞避免

判断拥塞发生: 发送方没有按时收到ACK.

![AIMD](/wiki/wiki/tcp-aimd.jpg)

AIMD, additive increase multiplicative decrease, 加法增大 乘法减小

初始化一个很大的 慢开始门限 `ssthresh` (slow start thresh),
初始化 拥塞窗口 `cwnd` (congestion window) 为一个 最大分段大小 `MSS` (maximum segment size).

开始传输, 每经过一个传输轮次 (transmission round), 将 cwnd 加倍. 该过程即 `慢开始`, 呈指数增长.

当遭遇一个拥塞, 将 ssthresh 设置为当前 cwnd 的一半, 然后从头开始 `慢开始` , 即 `乘法减小` .

当 cwnd 大于 ssthresh 之后还没有遭遇拥塞, cwnd 的增长策略切换为 `拥塞避免`, 每经历一个传输轮次后 cwnd 加一个 MSS , 呈线性增长, 即 `加法增大` .


## 快重传和快恢复

发送方窗口上限值: Min[rwnd, cwnd]


### 快重传
当接收方收到乱序分组时, 立即发送最新的合法ACK, 再收到乱序分组再发最新的合法ACK.(暗示说该ACK的下一个分组未到)
当发送方连续收到三次相同的ACK时, 就会意识到该ACK的下一个分组未到, 则重发按个分组.

### 快恢复
发送端响应快重传 重发分组后, 将 ssthresh 减半, 将 cwnd 从该值开始加法增长(拥塞避免算法).


