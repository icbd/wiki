---
layout: post
title:  HTTP Condition Request on Rails
date:   2018-06-24
categories: Rails
---

## HTTP Condition Request

### 概念回顾

所谓条件请求, 就是 Server 根据请求头的条件的不同而返回不同的响应.

这里所说的条件即验证器, 有两种: 

 最后修改时间 (last-modified) 和 内容指纹 (etag), 可以单独使用或者联合使用.

验证的过程区分 `强验证` 还是 `弱验证`.
 
 `强验证` 要求内容完成相同.
 
 `弱验证` 只要求主体内容相同, 允许部分片段有差异, 具体规则自定义.

|验证类型x验证器|最后修改时间|内容指纹|
|---|---|---|
|强验证|none|逐bit比较,要求完全相同|
|弱验证|none|内容主体相同,允许部分变化|


### 例子

#### 第一次GET请求 2.json

Request 无特殊 Header.

Response 返回内容的同时, 在 Header 中设置了 `ETag` 和 `Cache-Control`.

![/wiki/wiki/new-request.png](/wiki/wiki/new-request.png)


`Cache-Control` 中,

`max-age=0` 表示0秒后资源过期, 也就是每次都要检查缓存, 如果缓存还新鲜就用缓存.
 `no-cache` 也要求很次都检查缓存, 但强制要求重新请求, 不使用缓存, 即使缓存可用.
 
`private` 表示仅允许 user-agent 缓存该请求, 不允许代理服务器缓存.
 相对应的 `public` 允许 user-agent 和代理服务器缓存该请求.
 
 `must-revalidate` 表示需要在使用缓存前校验缓存状态, 不允许使用过期的缓存. 

#### 第二次GET请求 2.json (内容没有修改)

Request 携带了上一次的 `ETag` 值, 放在 `If-None_Match` 中.

Response 取请求头中的内容指纹, 跟准备返回的内容的指纹做比对, 如果内容一致就响应 `304`.

![/wiki/wiki/second-request.png](/wiki/wiki/second-request.png)

指纹中 `W/` 表示当前使用的是 弱验证, `W` 大小写敏感.

#### 第三次GET请求 2.json (内容存在修改)

Request 依然携带上一次的ETag值.

Response 判断内容有更新(指纹不一致), 响应 `200` , 发送新的内容.

![/wiki/wiki/third-request.png](/wiki/wiki/third-request.png)


## Rails 的实现

```ruby
  # GET /products/1
  # GET /products/1.json
  def show
  end
```

刚才GET请求对应的show方法如上, 也就是说这些处理过程都是自动完成的 :)  

正常的处理完成, 并且是 `200` 或 `201` 的响应, 并且需要检查缓存时, 
Rack 计算 body 的 SHA256, 设置 `ETag` 和 `Cache-Control` .

> `rack/etag`

```ruby
    def skip_caching?(headers)
      (headers[CACHE_CONTROL] && headers[CACHE_CONTROL].include?('no-cache')) ||
        headers.key?(ETAG_STRING) || headers.key?('Last-Modified')
    end

    def digest_body(body)
      parts = []
      digest = nil

      body.each do |part|
        parts << part
        (digest ||= Digest::SHA256.new) << part unless part.empty?
      end

      [digest && digest.hexdigest.byteslice(0, 32), parts]
    end
```

默认的验证规则实际上是强验证, 因为此时并没有定义弱验证规则, 是对 body 整体的 hash.

如果我们需要自定义弱验证规则, 可以使用 Rails 的 `stale?` 和 `fresh_when` .

### 例子

例如 product 的 GET 请求, 如果我们定义只有产品的价格有变化才算是有效变化, 其他变化都可以忽略.

```ruby
  def show
    fresh_when(@product.price)
  end
```

只修改 product 描述的时候, server 响应 `304`, 浏览器依然使用旧的缓存;
 修改价格后, 响应 `200` 并返回新的内容.
 
 > actionpack-5.1.6/lib/action_controller/metal/conditional_get.rb
 
```ruby
def fresh_when(object = nil, etag: nil, weak_etag: nil, strong_etag: nil, last_modified: nil, public: false, template: nil)
      weak_etag ||= etag || object unless strong_etag
      last_modified ||= object.try(:updated_at) || object.try(:maximum, :updated_at)

      if strong_etag
        response.strong_etag = combine_etags strong_etag,
          last_modified: last_modified, public: public, template: template
      elsif weak_etag || template
        response.weak_etag = combine_etags weak_etag,
          last_modified: last_modified, public: public, template: template
      end

      response.last_modified = last_modified if last_modified
      response.cache_control[:public] = true if public

      head :not_modified if request.fresh?(response)
    end
```

在这个例子中, object 是 `@product.price`, 它没有 `updated_at` 方法, Server 便不会设置 `Last-Modified` 头.

浏览器收不到 `Last-Modified` 就不会在下一次GET请求中携带 `If-Modified-Since`, 也就是说这种情况下, 只通过内容指纹进行验证.

如果object有 `updated_at` 方法, Server 会自动设置 `Last-Modified` .

当然也可以手动设置, 如 `fresh_when(@product.price, last_modified: Time.now)` ,这样也会令每次的缓存都失效.


还可以把 etag 声明到控制器中: 

```ruby
class ProductsController < ApplicationController
  # sth...
  etag { @product.try :price }
  
  def show
    fresh_when @product
  end
  # sth...
end
```

需要注意的是在方法中仍要使用 `fresh_when` 或 `stale?` ,否则使用默认的策略.

> actionpack-5.1.6/lib/action_controller/metal/conditional_get.rb

```ruby
      def etag(&etagger)
        self.etaggers += [etagger]
      end
      
      private
        def combine_etags(validator, options)
          [validator, *etaggers.map { |etagger| instance_exec(options, &etagger) }].compact
        end
``` 


## 拓展阅读

[https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Conditional_requests](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Conditional_requests) 

[https://stackoverflow.com/questions/1046966/whats-the-difference-between-cache-control-max-age-0-and-no-cache](https://stackoverflow.com/questions/1046966/whats-the-difference-between-cache-control-max-age-0-and-no-cache)

[https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control)

[https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/ETag](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/ETag)

[https://ruby-china.github.io/rails-guides/caching_with_rails.html#conditional-get-support](https://ruby-china.github.io/rails-guides/caching_with_rails.html#conditional-get-support)