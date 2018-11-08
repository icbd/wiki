---
layout: post
title:  LeetCode No.58 length-of-last-word  
date:   2018-11-08
categories: algorithm
---

```ruby

# @param {String} s
# @return {Integer}
def length_of_last_word(s)
  s.to_s.split(" ").pop.to_s.length
end

```