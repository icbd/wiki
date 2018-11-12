---
layout: post
title:  LeetCode No.198 house-robber  
date:   2018-11-12
categories: algorithm
---

```ruby

# @param {Integer[]} nums
# @return {Integer}
def rob(nums)
    @buffer = {}
    dp(nums)
end

def dp(nums)
  return 0 if nums.empty?
  
  @buffer[nums.size] ||= [
    dp(nums[0...-1]), 
    nums.last + dp(nums[0...-2])
  ].max
end

```