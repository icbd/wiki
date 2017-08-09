---
layout: post
title:  像PHP的die方法一样终结Rails的render
date:   2017-08-09
categories: Rails
---

## 场景是这样的:
Redis中用String型存了用户登录令牌, key是令牌, value是该用户的ID.
定义一个auth方法, 如果根据令牌能读到合法的用户ID, 就意味着该令牌有效而且能获取ID.

在一部分接口中需要登录才能操作, 所以希望一旦令牌非法, auth方法直接render错误码然后终结后续操作.
这个场景在PHP中可以用 `die("err_info");` 来处理.

[4-ways-to-early-return-from-a-rails-controller](http://blog.arkency.com/2014/07/4-ways-to-early-return-from-a-rails-controller/)
这篇文章提到了几个实用方法, 利用返回值和return的组合.
但我想要的是一旦触发一个条件, 无论是在Controller还是在某个方法里, 立即render结果并终结后续操作.

## 解决方案

利用异常.

```
module DiyExceptions
  class RenderAndDie < StandardError
  end
end
```

```
class ApplicationController < ActionController::API
  # sth...

  # 类比PHP die()
  rescue_from DiyExceptions::RenderAndDie do |ex|
    msg = JSON(ex.message) rescue [1, "RenderAndDie"]
    resp = {
        code: msg[0],
        info: msg[1]
    }
    render json: resp

    if Rails.env.development?
      p ">>>"
      p resp
      p "<<<"
    end
  end


  # 完全成功的请求
  # 直接结束请求
  def success(info)
    raise DiyExceptions::RenderAndDie, [0, info].to_json
  end


  # 业务上失败的请求, code > 0
  # 直接结束请求
  def failed(code, info)
    raise DiyExceptions::RenderAndDie, [code, info].to_json
  end

  # sth...
end
```

如此, 实用 failed 或 success 方法就可以啦 ;)

