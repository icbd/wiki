---
layout: post
title:  LeetCode Ruby No.66 plus-one  
date:   2018-11-08
categories: algorithm
---

```ruby

# @param {Integer[]} digits
# @return {Integer[]}
def plus_one(digits)
  (digits.join.to_i + 1).to_s.split("").map(&:to_i)
end

# p plus_one [4, 3, 2, 1]

```