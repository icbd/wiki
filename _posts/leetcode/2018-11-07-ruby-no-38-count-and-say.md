---
layout: post
title:  LeetCode Ruby No.38 count-and-say  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {Integer} n
# @return {String}
def count_and_say(n)
  return "1" if n == 1
  return "11" if n == 2

  result = "1"
  (2..n).each do
    result = read(result)
  end

  result
end

# "1211" => "111221"
def read(str)
  result = ""

  str_characters = str.to_s.split("")

  buffer = []
  str_characters.each_with_index do |character, index|

    if buffer.empty?
      buffer << character
    else
      if buffer.first == character
        buffer << character
      else
        result << read_unit(buffer)

        # 清空buffer; 将character push 进去
        buffer = [character]
      end
    end
  end

  unless buffer.empty?
    result << read_unit(buffer)
  end

  result
end

# 1 => 11
# 2 => 12
# 11 => 21
# 111 => 31
def read_unit(buffer)
  "#{buffer.size}#{buffer.first}"
end

# p read "1211"
# 30.times {|i| p count_and_say(i+1)}

```

## 递归

主函数也可以写出递归的样子, 好看但是效率差

```ruby

def count_and_say(n)
  return "1" if n == 1
  read count_and_say(n - 1)
end

```