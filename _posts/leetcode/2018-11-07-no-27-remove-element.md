---
layout: post
title:  LeetCode No.27 remove-element  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {Integer[]} nums
# @param {Integer} val
# @return {Integer}
def remove_element(nums, val)
  counter = 0
  nums.each do |num|
    if num != val
      nums[counter] = num
      counter += 1
    end
  end

  counter
end

# arr = [0,1,2,2,3,0,4,2]
# p remove_element(arr, 2)
# p arr

```