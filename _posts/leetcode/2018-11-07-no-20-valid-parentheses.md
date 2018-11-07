---
layout: post
title:  LeetCode No.20 valid-parentheses  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {String} s
# @return {Boolean}
def is_valid(s)
  origin_characters = s.split('')
  buffer = []

  s.length.times do
    character = origin_characters.shift
    next if character.empty?

    if buffer.empty?
      buffer << character
    else
      poped = buffer.pop
      if matching(poped, character)
        # 配对成功, 即弹出
        next
      else
        # 配对失败, 则都重新入栈
        buffer << poped
        buffer << character
      end
    end
  end

  # 如果 buffer 为空, 则全部成功匹配
  buffer.empty?
end

def matching(left, right)
  tab = {
      "(" => ")",
      "[" => "]",
      "{" => "}",
  }.freeze

  if tab[left] && tab[left] == right
    true
  else
    false
  end

end

# p is_valid "{[[]]}"

```