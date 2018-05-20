---
layout: post
title:  Ruby Proc return  
date:   2018-05-08
categories: Ruby
---

```ruby
def func(array, &block)
  array.each do |ele|
    block.call(ele)
  end
end

fruits = ["banana", "apple", "pear", "peach"]
func(fruits) do |f|
  break if f == "pear"
  puts "I like" + f.capitalize
end
```

处理水果数组, 遇到 pear 就终止, 用 `break`; 遇到 pear 就跳过, 用 next .

这里一定不能用的是 `return`, 会报 `LocalJumpError` .

## 解释

定义 func 的时候, 参数中的 `&block` 表明, 在 func 内, block 将被当做 Proc 对象使用.

proc 中的return, 从定义 proc 的作用域中返回, 也就是例子中的顶层作用域. 在顶层return就会报错.

lambda 的行为更像是方法, return 就是从本 lambda 返回.