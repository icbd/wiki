---
layout: post
title:  LeetCode Ruby No.69 sqrtx  
date:   2018-11-08
categories: algorithm
---

# 二分法

```ruby

# @param {Integer} x
# @return {Integer}
def my_sqrt(x)
  return 0 if x == 0
  return 1 if x < 4

  calc(x)
end

def calc(x, s = 0, e = x)
  mid = (s + e) / 2
  return mid if mid * mid <= x and (mid + 1) * (mid + 1) > x

  if mid * mid > x
    e = mid - 1
  else
    s = mid + 1
  end

  calc(x, s, e)
end

```