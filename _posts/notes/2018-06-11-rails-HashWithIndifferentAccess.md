---
layout: post
title:  HashWithIndifferentAccess  
date:   2018-06-11
categories: Rails
---

Rails 对 Hash 做了扩展, 其中之一是 `HashWithIndifferentAccess` .

他的作用是消除 `Hash` 键的 Symbol 和 String 的差异(统一转换为 String).

```ruby
require "active_support/core_ext/hash/indifferent_access"

origin_hash = {a: {b: {c: "CcC"}}}

rails_hash = ActiveSupport::HashWithIndifferentAccess.new origin_hash
# {"a"=>{"b"=>{"c"=>"CcC"}}}

rails_hash['new_key'] = "new value"
# {"a"=>{"b"=>{"c"=>"CcC"}}, "new_key"=>"new value"}

rails_hash[:new_key] = "update value"
# {"a"=>{"b"=>{"c"=>"CcC"}}, "new_key"=>"update value"}
```

`HashWithIndifferentAccess` 不会自动注入到 `Hash` 中, 只是在需要用的地方把 `Hash` 转为 `HashWithIndifferentAccess`.

需要注意的是:
 如果构造函数的入参 origin_hash 同时中含有 `"key"` 和 `:key`,
 并不能保证最终得到留下的是哪个值, 因为 `each_pair` 方法不能保证遍历的顺序.

>activesupport/lib/active_support/hash_with_indifferent_access.rb

```ruby
def initialize(constructor = {})
  if constructor.respond_to?(:to_hash)
    super()
    update(constructor)

    hash = constructor.to_hash
    self.default = hash.default if hash.default
    self.default_proc = hash.default_proc if hash.default_proc
  else
    super(constructor)
  end
end

   
def update(other_hash)
  if other_hash.is_a? HashWithIndifferentAccess
    super(other_hash)
  else
    other_hash.to_hash.each_pair do |key, value|
      if block_given? && key?(key)
        value = yield(convert_key(key), self[key], value)
      end
      regular_writer(convert_key(key), convert_value(value))
    end
    self
  end
end
``` 


常见的例子如 `Parameters` :

```
 params
=> <ActionController::Parameters {"utf8"=>"✓", 
"authenticity_token"=>"dFQ+iub6El78XUyjgzYgKkwdCOMCu+e/WhJ5f7styIXTHzu/JFbLCZE02o+CSbYQTPyJcjquXTbj8fpBaLL/GQ==", 
"commit"=>"Create User", "controller"=>"users", "action"=>"create"} permitted: false>
[2] pry(#<UsersController>)> params.class
=> ActionController::Parameters
[3] pry(#<UsersController>)> params[:utf8]
=> "✓"
[4] pry(#<UsersController>)> params["utf8"]
=> "✓"
```