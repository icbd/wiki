---
layout: post
title:  Rails 时区
date:   2017-10-30
categories: Rails
---

在默认设置下, Time.zone 为 UTC 时间, 数据库也存储 UTC 时间.

当我们想给用户显示当地时间时就需要使用 local 系列的时间函数, 这个函数会读配置里的时区信息.

> 当地时间 = UTC时间 + 当地时差

简单粗暴的方法是直接在Rails的配置文件里写:

```
config.time_zone = 'Asia/Shanghai'
config.active_record.default_timezone = :local
```

如此, 页面和数据库都显示为本地时间, 对于没有国际化要求的项目来说就足够了.

但这不是推荐的做法, 因为数据库最好是以统一的 UTC 时间存储为好.

我的做法是使用默认设置, 在 ApplicationController 中设置:

```
  before_action do
    # 只有明确指定en才使用英文翻译, 其余默认使用中文翻译
    if cookies[:lang] == 'en'
      I18n.locale = 'en'
      Time.zone = "America/Los_Angeles"
    else
      # default
      I18n.locale = 'zh'
      Time.zone = "Asia/Shanghai"
    end
  end
```

补充一点: I18n 只负责国际化的显示部分, 不参与时区逻辑的处理.


> config.active_record.default_timezone 设定从数据库中检索日期和时间时使用 Time.local（设为 :local 时）还是 Time.utc（设为 :utc 时）。默认为 :utc。