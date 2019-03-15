---
layout: post
title:  Ruby strip chomp
date:   2019-03-15
categories: Ruby
---

这两个单词超级眼熟, 但是讲具体差别可能就想去查文档了~

## 英文本意

strip 是 `脱去,剥去` 的意思, `stripper` 是脱衣舞娘.

chomp 是 `咬牙切齿, 大声咀嚼` 的意思, 可以想成咬掉什么.

## 处理方向

strip 处理字符串两端. 他有两个兄弟 `lstrip` 和 `rstrip` 可以限定只处理一端.

chomp 只处理字符串结尾.

## 处理内容

strip 处理空白字符, 包括**任意个** `space \t \r \n`.

chomp 在传参数的时候, 只处理紧跟字符串末尾的**一个** `\n` 或 `\r` 或 `\r\n`, 注意不包括 `\n\r`.

## Reference

[https://www.quora.com/What-is-the-difference-between-chomp-and-strip-in-Ruby](https://www.quora.com/What-is-the-difference-between-chomp-and-strip-in-Ruby)