---
layout: post
title:  LeetCode reverse-integer  
date:   2018-11-06
categories: algorithm
---

```ruby

# @param {Integer} x
# @return {Integer}
# require 'pry'

def reverse(x)
  doorsill_min = -1 * (2 ** 31)
  doorsill_max = 2 ** 31 - 1

  # 符号标记
  sign = (x < 0) ? "-" : ""

  # 把数字打散, 然后翻转数组
  reverse_arr = x.abs.to_s.split('').reverse

  # 去除前导0
  while reverse_arr.first == "0"
    reverse_arr.shift
  end

  # 补齐符号标记
  reverse_arr.unshift(sign)

  # 组装
  result = reverse_arr.join.to_i

  # 溢出处理
  if result >= doorsill_min and result <= doorsill_max
    result
  else
    0
  end
end

# p reverse(120)

```