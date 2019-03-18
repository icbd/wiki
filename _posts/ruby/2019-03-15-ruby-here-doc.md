---
layout: post
title:  Ruby here document  
date:   2019-03-15
categories: Ruby
---

### 最基本用法

`<<` 后跟一个标记字符, 中间写内容, 在新的一行顶格重复标记字符.

* 标记一般都大写, 小写在语法上也可以.

* 结束行必须顶格, 没有前导空格.

* 中间内容会生成原样的带换行的字符串

```ruby
str = <<hello
你好:
  Hello, world!
hello
p str
=begin
"你好:\n  Hello, world!\n"
=end

```

* 也可以在标记字符两边加引号

```ruby
str = <<"hello"
你好:
  Hello, world!
hello

str = <<'hello'
你好:
  Hello, world!
hello
```

### 插值

字符串插值适用:

```ruby
name = "小红"
str = <<MAIL
你好#{name}:
  Hello, world! 
#{Time.now}
MAIL
p str
=begin
"你好小红:\n  Hello, world! \n2019-03-15 17:47:21 +0800\n"
=end
```

### 连续标记

```ruby
str1, str2 = <<NAME, <<AGE
This is 小明.
NAME
I'm 18.
AGE
p str1, str2
=begin
"This is 小明.\n"
"I'm 18.\n"
=end
```

```ruby
def func(a:, b:, c:)
  p a, b, c
end

func a: <<PARAM_A, b: <<PARAM_B, c: '啦啦啦'
Hello
PARAM_A
world
PARAM_B
=begin
"Hello\n"
"world\n"
"啦啦啦"
=end
```

### 修饰方法

可以在标记字符串后面紧方法调用, 来处理返回的字符串:

```ruby
def func(name: '小明')
  str = <<MAIL.upcase
    你好#{name}:
  Hello, world!
MAIL
end

p func
=begin
"    你好小明:\n  HELLO, WORLD!\n"
=end
```

### 处理对齐

`<<HERE_DOC` 要求标记顶格写, 为了美化缩进, 此时换用可以 `<<-HERE_DOC`: 

```ruby
def func(name: '小明')
  str = <<-MAIL
    你好#{name}:
  Hello, world!
  MAIL
end

p func
=begin
"    你好小明:\n  Hello, world!\n"
=end
```

### 前导空格的处理

但是为了对齐的美观, 就会徒增一些前导空格. Rails提供了一个方法, 以非空行的第一个字符为基准, 去掉其他行的前导空格:

```ruby
require 'active_support/core_ext/string'

def func(name: '小明')
  str = <<MAIL.upcase.strip_heredoc
    你好#{name}:
  Hello, world!
MAIL
end

p func
=begin
"  你好小明:\nHELLO, WORLD!\n"
=end
```
