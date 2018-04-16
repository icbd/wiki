---
layout: post
title:  Rails 自定义异常
date:   2018-04-16
categories: Rails
---

在 `your_project/app/` 下新建 `lib` 目录, 添加文件 `exceptions.rb`:

```
module Exceptions
  class DockerApiError < StandardError
    def initialize(msg = nil)
      @docker_api_error_msg = msg
    end

    def message
      @docker_api_error_msg || "default error msg"
    end
  end
end
```

抛异常:

```
raise Exceptions::DockerApiError
raise Exceptions::DockerApiError, "special error msg"
```

