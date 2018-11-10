---
layout: post
title:  LeetCode Ruby No.9 palindrome-number  
date:   2018-11-06
categories: algorithm
---

```ruby

# @param {Integer} x
# @return {Boolean}
def is_palindrome(x)
  # 负数直接判为错
  return false if x < 0
  # 单数直接判为对
  return true if x >= 0 and x <= 9

  # 打散为数组
  item_list = x.to_s.split('')
  len = item_list.size
  
  # len是奇数或偶数不影响结果
  len_half = len / 2

  len_half.times do |index|
    if item_list[index] != item_list[len - 1 - index]
      return false
    end
  end

  true
end

# p is_palindrome(12321)

```