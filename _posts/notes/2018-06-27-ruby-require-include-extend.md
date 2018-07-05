---
layout: post
title:  Ruby require include extend  
date:   2018-06-27
categories: Ruby
---

很惭愧的说, 今天才稍稍理解了这几个加载的区别.

## require

```ruby
puts $LOAD_PATH
puts "----------------"
require 'active_model'
puts $LOAD_PATH
```

全局变量 `$LOAD_PATH` 顾名思义, 就是 Ruby 的加载路径. Ruby 只会在这些路径下查找.

```text
/Users/focus/.rvm/gems/ruby-2.4.1@global/gems/did_you_mean-1.1.0/lib
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby/2.4.0/x86_64-darwin17
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby/2.4.0/x86_64-darwin17
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/2.4.0/x86_64-darwin17
----------------
/Users/focus/.rvm/gems/ruby-2.4.1@global/gems/did_you_mean-1.1.0/lib
/Users/focus/.rvm/gems/ruby-2.4.1/gems/concurrent-ruby-1.0.5/lib
/Users/focus/.rvm/gems/ruby-2.4.1/gems/activesupport-5.1.6/lib
/Users/focus/.rvm/gems/ruby-2.4.1/gems/activemodel-5.1.6/lib
/Users/focus/.rvm/gems/ruby-2.4.1/gems/i18n-1.0.1/lib
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby/2.4.0/x86_64-darwin17
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/site_ruby
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby/2.4.0/x86_64-darwin17
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/vendor_ruby
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/2.4.0
/Users/focus/.rvm/rubies/ruby-2.4.1/lib/ruby/2.4.0/x86_64-darwin17
```

在启动解释器的时候可以用 `-I=/your_path/` 的参数把自定义的路径加到 Ruby 的 `$LOADPATH` 中.

```bash
ruby -I=/Users/focus/Coding/  main.rb
```

以下是官网的翻译:

> http://ruby-doc.org/core-2.5.0/Kernel.html#method-i-require

### require(name) -> true or false

> 加载name, 如果成功返回 `true`, 如果已经加载就返回 `false`.
  如果文件名不是绝对路径, 就从 `$LOADPATH` (`$:`) 所列出的路径下查找.
  如果文件扩展名是 `.rb`, 就作为源文件加载; 
  如果扩展名是 `.so` `.o` `.dll` 或者当前平台上其他的默认共享库扩展, Ruby 会把他们当做 Ruby 扩展来加载.
  如果没有扩展名, Ruby 会试图自动添加 `.rb` `.so` 等等 的扩展名然后再加载.
  如果找不到就抛 `LoadError` 的异常.

> For Ruby extensions the filename given may use any shared library extension. For example, on Linux the socket extension is “socket.so” and require 'socket.dll' will load the socket extension.

> 已经加载文件的绝对路径被添加到 `$LOADED_FEATURES` 中 (`$"`), 不会重复加载同一个文件.
  比如, `require 'a'` 之后, 不会重复加载 `require './a'` .
  被加载的源文件中的所有常量和全局变量, 在被调用程序的全局空间上可用. 但是局部变量不会被传播到加载环境中.


require 不是关键字, 是方法.

> 在 Ruby 1.8 時代，Ruby 的 require 就是普通的 require，在 Ruby 1.9 之後，require 的事情則是交給 rubygems 套件來管理 


## include 和 extend

他们的作用是把模块里的方法加到当前模块/类上.

`include` 将目标方法加入到当前位置(一般作为实例方法), `extend` 将目标方法加入到当前位置之上(一般作为类方法).

```ruby
module Tool
  def say
    puts "say hi."
  end
end

class C1
  # 将 Tool 中的方法加入到 C1 内, 作为实例方法
  include Tool
end
C1.new.say

class C2
  # 将 Tool 中的方法加入到 C2 上, 作为类方法
  extend Tool
end
C2.say
```

`include` 是定义在 `Module` 上的方法; 
 
`extend` 是定义在 `Object` 上的方法.

## Hook

```ruby
module MM
  def hi
    puts "MM"
  end
end

module M
  def self.included(base)
    puts "#{base} has been included"
  end

  def self.extended(base)
    base.extend MM
    puts "#{base} has been extended"
  end
end

class C
  include M
  extend M

  def hello
    puts "this is C instance"
  end
end

C.hi
```

## 使用模块内的子模块来分发实例方法和类方法

```ruby
module M
  module M_to_include
    def hi
      "hi of M_to_include "
    end
  end

  module M_to_extend
    def hi
      "hi of M_to_extend"
    end
  end

  def self.included(base)
    base.include M_to_include
    base.extend M_to_extend
  end
end

class C
  include M
end

puts C.new.hi
# hi of M_to_include
puts C.hi
# hi of M_to_extend
```


## 扩展阅读 

[https://kaochenlong.com/2016/05/01/require/](https://kaochenlong.com/2016/05/01/require/)

[https://ruby-china.org/topics/35350](https://ruby-china.org/topics/35350)

[https://ruby-china.org/topics/26038](https://ruby-china.org/topics/26038)

[https://ruby-china.org/topics/26037](https://ruby-china.org/topics/26037)

[https://ruby-china.org/topics/26036](https://ruby-china.org/topics/26036)

[https://blog.csdn.net/sunset108/article/details/48956101](https://blog.csdn.net/sunset108/article/details/48956101)