---
layout: post
title:  Ruby 请求不可信任站点
date:   2018-02-05
categories: Ruby
---

```
OpenSSL::SSL::SSLError does not match the server certificate
```

开始总是报服务器证书不匹配. 最简单的解决办法, 略去验证就好了: `:verify_mode => 0`


```
require 'net/http'

uri = URI('https://115.159.131.165/channel/899/senses')

Net::HTTP.start(uri.host, uri.port, :use_ssl => true, :verify_mode => 0) do |http|
  request = Net::HTTP::Get.new uri
  response = http.request request
  puts response.body
end
```

