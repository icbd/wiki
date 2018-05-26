---
layout: post
title:  小脚本方便编译执行golang
date:   2018-05-26
categories: BASH 
---

使用方式: macos 复制以下至 `~/.bash_profile`

```bash
# 编译并执行当前目录下的简单golang程序, 之后清理可执行文件
# example:
# $ g hello.go
# or
# $ g hello
g() {
	PARAM=$1
	filename_without_extension=${PARAM%.go*}
	# echo $filename_without_extension

	if [ -f "$filename_without_extension.go" ]
	then
 		/usr/local/go/bin/go build "$filename_without_extension.go"; 
		/bin/ls -alFh ./"$filename_without_extension"
		./"$filename_without_extension";
		rm ./"$filename_without_extension";
	else
 		echo "当前目录没找到: $filename_without_extension.go"
	fi
}
```