---
layout: post
title:  Golang package basic
date:   2019-07-25
categories: golang
---

### Code

```text
.
└── src
    ├── logger
    │   └── start.go
    ├── main.go
    └── third
        ├── external.go
        └── inner.go
```

> src/main.go

`_ "./logger"` 这里的 `_` 就如同赋值操作时忽略某些值一样, 这里表示引入这个 package 但不使用它. 引入 package 的一个副作用是执行这些文件的 `init()` 方法.

这里引入了 `logger` , 就会执行其中的 `init()`.

```go
package main

import (
	"fmt"

	_ "./logger"
	vendor_pkg "./third"
)

// Name : Global var in main
var Name = "DEF at main.go"

func init() {
	Name = "INIT at main.go"
}

func main() {
	fmt.Println("main.Name:  \t", Name)
	fmt.Println("third.Name: \t", vendor_pkg.Name)

	fmt.Println("\nthird#Hello:\t")
	vendor_pkg.Hello()
}

```

> src/logger/start.go

```go
package logger

import (
	"fmt"
	"time"
)

func init() {
	fmt.Println("Start at:", time.Now().Unix())
}

```

> src/third/inner.go

全局变量在 package 内部可以共享.

```go
package third

import "fmt"

func init() {
	Name = "INIT at inner.go"
}

// change_name : private method
func changeName(newName string) {
	Name = newName
	fmt.Println("---Do third#changeName---")
}

```

> src/third/external.go

想要对外暴露的需要首字母大写.

```go
package third

import "fmt"

// Name : Global var int third
var Name = "DEF at external.go"

// Hello : Public Method
func Hello() {
	changeName("Changed New Name")
	fmt.Println("Hi,", Name)
}

```