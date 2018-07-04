---
layout: post
title:  Ruby digest   
date:   2018-07-04
categories: Ruby
---

Ruby 里的 `Hash` 常用来说明 key-value 的数据结构. 哈希算法或者摘要算法常用 `digest` 来表示.

```ruby
require 'openssl'


digest = OpenSSL::Digest::SHA1.new
key = "key"
data = "将要被生成摘要的原文😝😁"


p binary_string = OpenSSL::HMAC.digest(digest, key, data)
# "\x9F\x01\xFA\x19M|\x9D\xE3\x18g\x91\x80\x10\xE9\x01[\x05A$\xD3"

p hex_encoded_string = OpenSSL::HMAC.hexdigest(digest, key, data)
# "9f01fa194d7c9de31867918010e9015b054124d3"


# 二进制字符串 与 十六进制字符串 相互转化
p binary_string == Array(hex_encoded_string).pack('H*')
# true
p binary_string.unpack('H*').join == hex_encoded_string
# true
``` 


```ruby
require 'openssl'


digest = OpenSSL::Digest::SHA1.new
key = "key"
data = "将要被生成摘要的原文😝😁"


# 默认的data为空字符串
hmac_instance = OpenSSL::HMAC.new(key, digest)

hex_encoded_string_with_null_string = hmac_instance.hexdigest
# "f42bb0eeb018ebbd4597ae7213711ec60760843f"

# reset 重置 data
hmac_instance.reset

hmac_instance.update("").hexdigest
# "f42bb0eeb018ebbd4597ae7213711ec60760843f"
# 使用空字符串更新, 结果不变
hmac_instance.update("").hexdigest
# "f42bb0eeb018ebbd4597ae7213711ec60760843f"

hmac_instance.update("xxx").hexdigest
# "ab6eea94fad146c7e2d10ad734e5d2b6c3626903"
# 使用其他字符串更新, 结果变化
hmac_instance.update("xxx").hexdigest
# "020776f4c2f1f5886063c72d5cda763d85679128"

hmac_instance.reset
hex_encoded_string = hmac_instance.update(data).hexdigest
# "9f01fa194d7c9de31867918010e9015b054124d3"


# 等效的写法
hex_encoded_string == OpenSSL::HMAC.hexdigest(digest, key, data)
# true
```