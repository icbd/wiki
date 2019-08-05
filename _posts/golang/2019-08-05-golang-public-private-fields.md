---
layout: post
title:  Golang 公开和非公开的标识符
date:   2019-08-05
categories: golang
---

公开还是非公开, 最基本的规则是根据大小写:

* 大写字母开头的就对包外公开
* 小写字母开头的就对包外非公开

下面DEMO展示其他具体的例子:

```text
.
├── go.mod
├── go.sum
├── main.go
└── utils
    └── entity.go
```

> utils/entity.go

```golang
package utils

import "fmt"

type user struct {
	Name string
	Age  int
}

type Soldier struct {
	user
	Level string
}

type admin struct {
	user
	role string
}

func NewAdin(name string, age int, role string) (*admin) {
	ad := &admin{
		user: user{Name: name, Age: age},
		role: role,
	}

	return ad
}

func (u *user) Say() {
	fmt.Println("为人民服务!")
}

func (ad *admin) Say() {
	fmt.Println("同志们辛苦了~")
}

```

> main.go

```golang
package main

import (
	"fmt"
	"hello/utils"
)

func main() {
	s := utils.Soldier{Level: "2"}
	s.Name = "列兵-甲"
	s.Age = 19
	fmt.Println(s)
	s.Say()

	ad := utils.NewAdin("蛤蛤", 90, "主席")
	fmt.Println(ad)
	ad.Say()
}

```

`user` 和 `admin` 在 main 中是不可见的, 他们在 main 中不能直接实例化.

但是非公共的可以通过方法返回. `NewAdin` 返回了一个 `*admin`, 在 main 中的`:=` 也能知道这个值是 `admin` 类型的.

`Soldier` 是公共的, 在 main 中可以直接实例化. 但是其中的 `user` 是非公共的, 不能在实例化的时候赋值. 但是 `user` 中的 `Name` 和 `Age` 又是公共的, 外部类型可以直接使用它们.

`Say()` 体现了多态.
