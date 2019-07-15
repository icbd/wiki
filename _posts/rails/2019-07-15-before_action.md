---
layout: post
title:  Execution order of before_action in Rails 
date:   2019-07-15
categories: Rails
---

一般情况 `Controller` 里都不会有太多的 `before_action`, 一旦需要使用多个的时候往往伴随着各个方法的顺序问题, 以下 DEMO :


`before_action` 就是根据顺序一个一个来, 队列模型;

`append_before_action` 根据定义顺序, 向 `before_action` 的队列中插入 callback ;

`prepend_before_action` 会插队执行, 多个方法的话会依次插入队列头(越晚声明的 callback 越先执行);

`skip_before_action` 从队列中剔除某 callback .

```ruby
class UsersController < ApplicationController
  append_before_action :m1
  before_action :m2
  append_before_action :m3
  before_action :m4, :m5
  before_action :m6
  append_before_action :m7
  prepend_before_action :m10, :m11
  before_action :m8, :m9
  skip_before_action :m8

  def index
    render json: User.all
  end

  private

  15.times do |i|
    define_method("m#{i}") do
      p __method__
    end
  end
end

```

```text
Started GET "/users" for ::1 at 
   (0.1ms)  SELECT sqlite_version(*)
Processing by UsersController#index as HTML
:m11
:m10
:m1
:m2
:m3
:m4
:m5
:m6
:m7
:m9
  User Load (0.1ms)  SELECT "users".* FROM "users"
  ↳ app/controllers/users_controller.rb:13:in `index'
Completed 200 OK in 6ms (Views: 4.4ms | ActiveRecord: 0.9ms | Allocations: 4236)
```


## 包含模块的情况

include 的模块跟类公用一个队列 (其实关键在 `ActiveSupport::Concern` 的 `included` 的实现).

根据代码的执行顺序, 依照之前的规则推定就不会有错啦, 以下 DEMO :


```ruby
module ConcernDemo
  extend ActiveSupport::Concern

  included do
    append_before_action :module_m1
    before_action :module_m2
    append_before_action :module_m3
    before_action :module_m4, :module_m5
    include ConcernDemo
    before_action :module_m6
    append_before_action :module_m7
    prepend_before_action :module_m10, :module_m11
    before_action :module_m8, :module_m9
    skip_before_action :module_m8
  end

  private

  15.times do |i|
    define_method("module_m#{i}") do
      p __method__
    end
  end
end

```

```ruby
class UsersController < ApplicationController
  append_before_action :m1
  before_action :m2
  append_before_action :m3
  before_action :m4, :m5
  
  include ConcernDemo
  
  before_action :m6
  append_before_action :m7
  prepend_before_action :m10, :m11
  before_action :m8, :m9
  skip_before_action :m8

  def index
    render json: User.all
  end

  private

  15.times do |i|
    define_method("m#{i}") do
      p __method__
    end
  end
end

```

output:

```text
Started GET "/users" for 127.0.0.1 at 
   (0.0ms)  SELECT sqlite_version(*)
Processing by UsersController#index as HTML
:m11
:m10
:module_m11
:module_m10
:m1
:m2
:m3
:m4
:m5
:module_m1
:module_m2
:module_m3
:module_m4
:module_m5
:module_m6
:module_m7
:module_m9
:m6
:m7
:m9
  User Load (0.2ms)  SELECT "users".* FROM "users"
  ↳ app/controllers/users_controller.rb:16:in `index'
Completed 200 OK in 13ms (Views: 10.6ms | ActiveRecord: 0.8ms | Allocations: 4457)
```

跟 `prepend_before_action` 替换顺序之后:

```ruby
class UsersController < ApplicationController
  append_before_action :m1
  before_action :m2
  append_before_action :m3
  before_action :m4, :m5
  before_action :m6
  append_before_action :m7
  prepend_before_action :m10, :m11

  include ConcernDemo

  before_action :m8, :m9
  skip_before_action :m8

  def index
    render json: User.all
  end

  private

  15.times do |i|
    define_method("m#{i}") do
      p __method__
    end
  end
end

```

output:

```text
Started GET "/users" for 127.0.0.1 at 
   (0.1ms)  SELECT sqlite_version(*)
Processing by UsersController#index as HTML
:module_m11
:module_m10
:m11
:m10
:m1
:m2
:m3
:m4
:m5
:m6
:m7
:module_m1
:module_m2
:module_m3
:module_m4
:module_m5
:module_m6
:module_m7
:module_m9
:m9
  User Load (0.2ms)  SELECT "users".* FROM "users"
  ↳ app/controllers/users_controller.rb:16:in `index'
Completed 200 OK in 7ms (Views: 4.5ms | ActiveRecord: 0.8ms | Allocations: 4395)
```
