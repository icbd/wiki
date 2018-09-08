---
layout: post
title:  Ruby 保留字  
date:   2018-09-08
categories: Ruby
---

> Ruby source code `defs/keywords`

| classify | items |
| --- | --- |
| 块 | `begin` `end` `do` `yield` |
| 魔术常量 | `__ENCODING__` `__LINE__` `__FILE__` |
| 流程控制 | `while` `until` `for` `in` `case` `when` `break` `next` `redo` `if` `then` `unless` `else` `elsif` `retry` `return` |
| 定义类模块方法 | `class` `module` `def` `undef` `defined?`|
| 布尔 | `true` `false` `nil` |
| 逻辑 | `and` `not` `or` |
| 引用 | `self` `super` |
| 异常 | `ensure` `rescue` |
| 别名 | `alias` |
| 顺序 | `BEGIN` `END` |


do 本身是保留字(reserve), 不能用于普通标识符.
但是可以用于不会产生语法歧义的位置, 比如:

方法名 `def do; end `

全局变量名 `$do`

实例变量名 `@do @@do`


```ruby
def do
  puts "this is do"
end

# 当前 self 是 main:Object
send(:do)
```