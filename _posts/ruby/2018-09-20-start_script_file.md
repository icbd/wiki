---
layout: post
title:  Ruby 启动脚本  
date:   2018-09-20
categories: Ruby
---

```ruby

if __FILE__ == $0
  puts "从当前脚本启动"
end

```

`__FILE__` 为本脚本名, `$0` 为启动脚本名. 