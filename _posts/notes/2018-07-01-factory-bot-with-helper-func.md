---
layout: post
title:  在 FactoryBot 中使用helper  
date:   2018-07-01
categories: Rails
---

## 在测试中使用帮助方法

在测试的 `helpers` 目录下新建文件, 使用 module 包装:

`extend self` 的作用是令模块内的方法(实例方法)在模块上也能用(模块方法).

> test/helpers/tools_helper.rb

```ruby
module ToolsHelper
  extend self

  def fake_phone
    phone = "188"
    8.times do
      phone += rand(10).to_s
    end

    phone
  end
end
```

在总的 test helper 文件中引入:

> test/test_helper.rb

```ruby
# sth...
require 'helpers/tools_helper'
# sth...

class ActiveSupport::TestCase
  include ToolsHelper
  # sth...
end
```

## 安装 Factory Bot

老版本原名 `FactoryGirl`

> Gemfile

```ruby
group :development, :test do
  # sth....
  gem 'factory_bot_rails', '~> 4.10'
end
```

> test/test_helper.rb

```ruby
# sth...
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  # sth...
end
```

新建 `factories` 目录, 为每个模型单独新建一个文件:

使用 `attribute_name value` 的形式来定义, `attribute_name` 其实是方法, `value` 是入参.
如果需要使用计算, 就传入block, 即用 `{}` 包装计算逻辑.

`{}` 跟 Hash 的表现有冲突, 所以想传入 Hash 的时候, 需要再加一个 `{}`, 如: `{{key: value}}` . 


在 `FactoryBot.define` 中调用帮助方法的模块方法: `ToolsHelper.fake_phone`.


> test/factories/users.rb

```ruby
FactoryBot.define do
  factory :user, class: User do
    phone {ToolsHelper.fake_phone}
    password "password"
    password_confirmation "password"
    is_valid true
  end
end
```

