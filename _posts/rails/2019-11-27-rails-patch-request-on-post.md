---
layout: post
title:  Rails 处理基于 POST 的 PATCH 请求
date:   2019-11-27
categories: Rails
---

HTTP METHOD:
* GET
* POST
* PATCH
* PUT
* HEAD
* DELETE
* OPTION

限于 HTML4.0 的 FORM 只支持 GET 和 POST, 如果想要触达其他的 METHOD, 就需要使用其他的迂回策略.

引入 `Rack::MethodOverride` 中间件可实现利用 POST 来发送其他类型的请求:
 
```ruby
config.middleware.insert_after Rack::Runtime, Rack::MethodOverride
```

该中间件允许两个 mock http method 的方式.

### 其一: 在请求头中使用 `X-HTTP-METHOD-OVERRIDE`

Request:
```text
POST /users/1 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 0
Host: localhost:3000
User-Agent: HTTPie/0.9.9
X-HTTP-METHOD-OVERRIDE: PATCH

```

### 其二: 在body中使用 `_method` 参数

该方法仅限于 form 表达的形式.

Request:
```text
POST /users/1 HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 13
Content-Type: application/x-www-form-urlencoded; charset=utf-8
Host: localhost:3000
User-Agent: HTTPie/0.9.9

_method=patch

```

`MethodOverride` 核心逻辑整理如下:

```ruby

def call(env)
    req = Request.new(env)
    method = req.POST[METHOD_OVERRIDE_PARAM_KEY] || env[HTTP_METHOD_OVERRIDE_HEADER]
    if HTTP_METHODS.include?(method)
      env[RACK_METHODOVERRIDE_ORIGINAL_METHOD] = env[REQUEST_METHOD]
      env[REQUEST_METHOD] = method
    end
    @app.call(env)
end

```
