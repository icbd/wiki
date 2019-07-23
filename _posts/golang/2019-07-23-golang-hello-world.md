---
layout: post
title:  golang hello world
date:   2019-07-23
categories: golang
---

## Golang Hello World

```text
.
└── src
    ├── goroute
    │   └── add.go
    └── main
        └── main.go

3 directories, 2 files
```


> src/goroute/add.go

```golang
package goroute

import "time"

// Add a and b
func Add(a int, b int, pipe chan int) {
	sum := a + b
	time.Sleep(time.Second * 3)
	pipe <- sum
}

```


> src/main/main.go

```golang
package main

import (
	"fmt"
	"time"

	"../goroute"
)

func main() {
	a := 10
	b := 3

	startAt := time.Now().Unix()

	pipe := make(chan int)

	fmt.Println("---1:", time.Now().Unix()-startAt)
	go goroute.Add(a, b, pipe)
	fmt.Println("---2:", time.Now().Unix()-startAt)
	sum := <-pipe
	fmt.Println("---3:", time.Now().Unix()-startAt)
	fmt.Println("sum:", sum)
	fmt.Println("---4:", time.Now().Unix()-startAt)
}

```

outputs:

```text
---1: 0
---2: 0
---3: 3
sum: 13
---4: 3
```