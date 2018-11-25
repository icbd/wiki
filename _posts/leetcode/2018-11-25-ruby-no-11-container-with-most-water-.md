---
layout: post
title:  LeetCode No.11 container-with-most-water
date:   2018-11-25
categories: algorithm
---

```ruby

# @param {Integer[]} height
# @return {Integer}
def max_area(height)
  left = 0
  right = height.size - 1
  max_container = 0

  while left < right
    h = [height[left], height[right]].min

    container = h * (right - left)
    if container > max_container
      max_container = container
      p [left, right]
    end

    if height[left] == h
      left += 1
    else
      right -= 1
    end
  end

  max_container
end

```