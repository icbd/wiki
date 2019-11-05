---
layout: post
title:  NGINX PUMA Sinatra Rack
date:   2019-11-04
categories: Ruby
---

当我们说 `Web Server` 的时候, 我们到底在说什么? 我们来看看这些组件是怎么相互协作的.

假设我们要部署一个 `http://icbd.devel` , 以自顶向下的顺序分析.

第一步当然是买域名, 设置 DNS 解析. 我们在本地模拟的话, 就直接在 `/etc/hosts` 里写入:

```text
127.0.0.1 icbd.devel
127.0.0.1 www.icbd.devel
```

然后配置 NGINX 的 vHost:

> /usr/local/etc/nginx/servers/icbd.devel.conf

```text
server {
    listen       80;
    server_name  icbd.devel www.icbd.devel;
    root /coding/trial/sinatra_demo/public;

    location ~ \.(jpg|jpeg|png|gif|ico)$ {
    }

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://localhost:3000;
    }
}
```

第一段 `location` 设置了 NGINX 直接对静态资源的服务;

第二段 `location` 把其他动态请求交给本地 3000 端口的服务来处理.

Rack 是直接处理 HTTP 协议的 GEM; Sinatra 是在 Rack 基础上构建的 Web Server Framework .
(用 Sinatra 举例的好处是它可以只在一个文件里定义MVC的所有)

> /coding/trial/sinatra_demo/app.rb

```ruby
# frozen_string_literal: true

require 'sinatra'

$counter ||= 0

get '/' do
  $counter += 1
  "index -- $counter:#{$counter}"
end

get '/sleep' do
  thread = Thread.new { sleep 5 }
  thread.join

  $counter += 100
  "sleep -- $counter:#{$counter}"
end

``` 

启动服务:

```bash
$ ruby app.rb -p 3000
```

浏览器访问:

```text
http://icbd.devel/
http://icbd.devel/sleep
```

看起来一切正常, NGINX 的 log 和 Sinatra 的 log 也都很清晰.
但是这里有一个问题, `/sleep` 是一个耗时的请求, 它会阻塞整个 Server, 在 5 秒之内, Server 不能响应其他动态请求.

这时候我们两种办法来解决:
1) 把 Sinatra 改造成非阻塞的; 
2) 把 Sinatra 放到一个支持多线程(或者多进程)的服务器容器里, 只需要保证 Sinatra 和我们的业务逻辑是线程安全的.

很明显方案2对开发人员更友好, 而且幸运的是, Sinatra 和 Rails 都是线程安全的. PUMA 就是帮我们实现方案2的 Web Server.
 
PUMA 位于 NGINX 和 Sinatra 之间, 接收 NGINX 传过来的请求交给某个 Sinatra 实例来处理.
PUMA 支持多进程多线程模式, 可以服务多个 Sinatra 实例. 如此一来, 就可以解决我们之前遇到的阻塞的情况了.

稍微调整一下 `app.rb`:
```ruby
# frozen_string_literal: true

require 'sinatra'

class App < Sinatra::Application
  $counter ||= 0
  get '/' do
    $counter += 1
    Rack::Utils.escape_html "#{self}  /index -- $counter:#{$counter}"
  end

  get '/sleep' do
    thread = Thread.new { sleep 5 }
    thread.join

    $counter += 100
    Rack::Utils.escape_html "#{self}  /sleep -- $counter:#{$counter}"
  end
end


```

用 rackup 的方式启动:

> config.ru

```ruby
# frozen_string_literal: true

require 'bundler/setup'
require './app'

App.run! port: 3000, handler_name: :puma

```

PUMA 的配置一般放在项目的 `config/puma.rb` 中:

```ruby
# frozen_string_literal: true

workers 2
threads 1, 2

preload_app!

```

最终的启动命令:

```bash
$ bundle exec rackup
```

rackup 会找到我们的 `App` 类, 把 `App` 交给指明的 handler -- PUMA 来处理.

这样启动的好处是运维不需要关心 PUMA 到底是怎么, 如果把 PUMA 切换到 `Thin` 或者 `WEBrick` 也不会改变启动命令.

项目结构:

```text
.
├── Gemfile
├── Gemfile.lock
├── app.rb
├── config
│   └── puma.rb
├── config.ru
└── public
    ├── index.html
    └── logo.jpg

```
