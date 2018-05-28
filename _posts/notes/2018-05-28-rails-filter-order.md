---
layout: post
title:  Rails 过滤器顺序 
date:   2018-05-28
categories: Rails
---

例子摘自同事的分享.

总体来说是顺序执行.

当多个过滤器同时使用时, `after` 过滤器会维护一个栈.

`around` 会一拆两份, `before` 和 `after`.

`before` 部分顺序执行, 包括 `around` 的 `before` 部分, 遇到 `after` 就入栈.

action 执行之后, 从栈顶依次弹出 `after` 来执行. 


```ruby
class HomeController < ApplicationController
  before_action :before1
  around_action :around1
  after_action :after1

  around_action :around2
  before_action :before2
  after_action :after2
  
  before_action :before3
  after_action :after3
  around_action :around3

  def index
    render plain: "Hello World"
  end

  def before1
    puts "before1"
  end

  def before2
    puts "before2"
  end
  
  def before3
    puts "before3"
  end

  def after1
    puts "after1"
  end

  def after2
    puts "after2"
  end
  
  def after3
    puts "after3"
  end

  def around1
    puts "around1 (before)"
    yield
    puts "around1 (after)"
  end

  def around2
    puts "around2 (before)"
    yield
    puts "around2 (after)"
  end
  
  def around3
    puts "around3 (before)"
    yield
    puts "around3 (after)"
  end
  
=begin
before1
around1 (before)
around2 (before)
before2
before3
around3 (before)
around3 (after)
after3
after2
around2 (after)
after1
around1 (after)
=end
end
```

数据库提交是类似的道理, `after_save` 直接执行. 

`after_commit` 先入栈, 到了执行步骤就依次出栈执行.


```ruby
class HomeController < ApplicationController
  def index
    User.create(user_key: 'hello_world', name: 'test')

    render plain: "Hello World"
  end
end

# user.rb

class User < ApplicationRecord
  after_commit :commit_log_1
  after_commit :commit_log_2

  after_save :save_log_1
  after_save :save_log_2

  private

  def save_log_1
    p "save log 1"
  end

  def save_log_2
    p "save log 2"
  end

  def commit_log_1
    p "commit log 1"
  end

  def commit_log_2
    p "commit log 2"
  end
end
=begin
"save log 1"
"save log 2"
"commit log 2"
"commit log 1"
=end
```