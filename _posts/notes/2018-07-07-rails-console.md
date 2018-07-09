---
layout: post
title:  something about Rails console  
date:   2018-07-07
categories: Rails
---

## 在 Rails console 中使用 path helper

```ruby
app.root_url
```

output:

```shell
"http://www.example.com/"
```

可以添加配置修改修改 hostname :

```ruby
Rails.application.configure do
  config.host_name = "localhost:3000"
  routes.default_url_options = {host: config.host_name}
end
```

读取配置:

```ruby
Rails.configuration.host_name
```

关于 path helper 方法, 是可以临时指定host的

```shell
app.root_url(host: "sb.baidu.com", protocol: "https")
```

output:

```shell
"https://sb.baidu.com/"
```

注意 `host` 参数只能指定 host, 即使写成 `ftp://baidu.com` 也会自动先把协议去掉. 协议默认 `http`, 接受 `protocol: ` 参数覆盖.


## 在 Rails console 里使用 FactoryBot

```ruby
  class Application < Rails::Application

    # rails console 中添加引用, 来使用FactoryBot
    console do
      require "#{config.root}/test/helpers/tools_helper.rb"
      Rails::ConsoleMethods.send :include, FactoryBot::Syntax::Methods
    end
  end
```