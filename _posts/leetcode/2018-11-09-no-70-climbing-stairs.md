---
layout: post
title:  LeetCode No.70 climbing-stairs  
date:   2018-11-09
categories: algorithm
---

# DP

面对每一个新的楼层:

1) 要么走一步(只有一种方法), 然后加之前的方法之和

2) 要么退回上一步, 合并成两步一起走(也只有一种方法), 然后再加再之前的和

最终公式是: f(n) = f(n-1) + f(n-2)

也就是卡特兰数的算法.

```ruby

# @param {Integer} n
# @return {Integer}
def climb_stairs(n)
  if n <= 3
    n
  else
    climb_stairs(n - 1) + climb_stairs(n - 2)
  end
end

```

很明显这个算法有效率问题, 应该缓存之前的结果避免重复计算.
ruby 用实例变量很容易实现.

```ruby

# @param {Integer} n
# @return {Integer}
def climb_stairs(n)
  @cache ||= {}

  result = nil
  if n <= 3
    result = n
  else
    result = (@cache[n - 1] || climb_stairs(n - 1)) + (@cache[n - 2] || climb_stairs(n - 2))
  end

  @cache[n] = result

  result
end

# p climb_stairs(44) 

```