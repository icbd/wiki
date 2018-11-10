---
layout: post
title:  LeetCode Ruby No.13 roman-to-integer
date:   2018-11-06
categories: algorithm
---

```ruby

# [segment, new_str]
def pop_segment(str, sign)
  i = str.index(sign)

  if i.nil?
    # 已经没有sign了
    ["", str]
  else
    # 切断
    [str[0..i], str[(i + 1)..-1]]
  end
end

# @param {String} s
# @return {Integer}
def roman_to_int(s)

  tab = {
      'M' => 1000,
      'D' => 500,
      'C' => 100,
      'L' => 50,
      'X' => 10,
      'V' => 5,
      'I' => 1,
  }

  result = 0
  tab.each do |sign, value|
    loop do
      segment, new_str = pop_segment(s, sign)
      if segment.empty?
        break
      else
        s = new_str
      end

      #  计算片段
      if segment.length == 1
        result += tab[segment]
      else
        result += tab[segment[1]] - tab[segment[0]]
      end
    end
  end

  result
end

# p roman_to_int("III")

```