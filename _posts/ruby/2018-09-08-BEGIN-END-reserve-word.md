---
layout: post
title:  Ruby 保留字之 BEGIN END  
date:   2018-09-08
categories: Ruby
---

查看ruby的保留字表(位于Ruby源码的`defs/keywords`), 会看到 `BEGIN` 和 `END` .

还从来没用过这两个大写的保留字~ 

下面是例子:

```ruby
puts ">>>No.1"
sleep 1
puts ">>>No.2"
END {
  puts "拖延症患者..."
}
puts ">>>No.3"

BEGIN {
  puts "先走一步!"
}
puts ">>>No.4"
```

输出结果: 

```text
先走一步!
>>>No.1
>>>No.2
>>>No.3
>>>No.4
拖延症患者...
```

效果是将 `BEGIN` 里的代码提到最前面执行, 将 `END` 里的代码推迟到最后执行.

如果使用多个 `BEGIN` 和 `END`, 会有堆栈的效果:

```ruby
puts "No.1"

BEGIN {
  puts "B1"
}

puts "No.2"

BEGIN {
  puts "B2"
}

puts "No.3"

END {
  puts "E1"
}

puts "No.4"

END {
  puts "E2"
}

puts "No.5"
```

输出结果:

```text
B1
B2
No.1
No.2
No.3
No.4
No.5
E2
E1
```

最后值得注意的是, 在新版的Ruby中, 只能在顶层使用这两个保留字, 否则会抛异常: `BEGIN is permitted only at toplevel` .


## 参考:
[https://stackoverflow.com/questions/15326167/what-are-the-reserved-words-begin-or-end-used-for-in-ruby](https://stackoverflow.com/questions/15326167/what-are-the-reserved-words-begin-or-end-used-for-in-ruby) 