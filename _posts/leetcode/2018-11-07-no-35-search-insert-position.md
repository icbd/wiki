---
layout: post
title:  LeetCode No.35 search-insert-position  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer}
def search_insert(nums, target)
  nums.each_with_index do |num, index|
    if target == num
      return index
    elsif target > num
      next
    else # target < num
      return index
    end
  end

  # 最大的一个
  nums.size
end

# p search_insert([1, 3, 5, 6], 0)

```