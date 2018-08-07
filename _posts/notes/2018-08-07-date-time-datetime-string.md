---
layout: post
title:  Ruby 时间与String相互转化  
date:   2018-08-07
categories: Ruby
---

在不适合传递对象的接口中, 会用到时间日期类型跟字符串的相互转化:

```ruby
require 'date' # 包含DateTime
require 'time'
```

## 时间日期转字符串
统一先转为Time再to_s方便 `parse`
```ruby
Time.now.to_s
Date.today.to_time.to_s
DateTime.now.to_time.to_s
```

# 字符串解析为时间日期
```ruby
Date.parse("2018-08-07 17:43:42 +0800")
DateTime.parse("2018-08-07 17:43:42 +0800")
Time.parse("2018-08-07 17:43:42 +0800")
```