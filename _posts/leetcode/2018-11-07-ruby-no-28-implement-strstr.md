---
layout: post
title:  LeetCode Ruby No.28 implement-strstr  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {String} haystack
# @param {String} needle
# @return {Integer}
def str_str(haystack, needle)
  return 0 if needle.empty?
  
  haystack.length.times do |i|
    return i if compare(needle, haystack[i..-1])
  end

  -1
end

# 默认 str1.length <= str2.length
# 判断str1是否为str2的"顶头子串" 
def compare(str1, str2)
  return false if str1.length > str2.length

  cursor = 0

  str1.length.times do
    break if str2[cursor].nil?
    return false if str1[cursor] != str2[cursor]

    cursor += 1
  end

  if str1[cursor].nil?
    true
  else
    false
  end

end

# p str_str "", ""

```