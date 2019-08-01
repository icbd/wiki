---
layout: post
title:  Golang go mod
date:   2019-08-01
categories: golang
---

Ruby 生态下有 RVM 来管理 Ruby 的版本, 有 bundle 来管理 Gem .
Golang 在 1.11 引入了 go mod, 解决了一些依赖管理的问题.

```text
.
└── hello.go
```

```golang
package main

import (
	"fmt"
	"github.com/appleboy/com/random"
)

func main() {
	fmt.Println("Hello Golang.")
	fmt.Println(random.String(10))
}

```

初始化 mod 

```bash
go mod init
```

会自动生成两个文件:

```text
.
├── go.mod
├── go.sum
└── hello.go

```

安装相关的依赖

```bash
go get
```

`go mod` 已经嵌入到 `go get` 的工具链中, 如果需要特定版本的依赖, 用 `go get` 获取这个包, `go.mod` 的信息就会自动更新:

```bash
 go get github.com/appleboy/com/random@v0.0.1
```
