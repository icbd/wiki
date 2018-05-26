---
layout: post
title:  小脚本方便编译执行golang
date:   2018-05-26
categories: BASH 
---

使用方式: macos 复制以下至 `~/.bash_profile`

```bash
# 编译并执行当前目录下的简单golang程序, 之后清理可执行文件
g() {
	if [ -f "$1.go" ]
	then
 		/usr/local/go/bin/go build "$1.go"; 
		/bin/ls -alFh ./"$1"
		./"$1";
		rm ./"$1";
	else
 		echo "当前目录没找到: $1.go"
	fi
}
```