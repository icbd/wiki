---
layout: post
title:  RobotsTXT
date:   2019-01-16
categories: translate
---

# 关于 /robots.txt

## 简介

网站所有者通过 `/robots.txt` 向网络爬虫解释说明他的网站; 这被称作 `机器人排除协议` .

工作原理如下: 一个网络爬虫想访问该网站的 URL `http://www.example.com/welcome.html` ,
在它访问 URL 之前, 它先检查 `http://www.example.com/robots.txt`, 看到: 

```text
User-agent: *
Disallow: /
```

`User-agent: *` 指这个内容对所有类型爬虫有效. `Disallow: /` 指爬虫不该访问该网站的任意页面.

两点重要的注意事项:

* 爬虫可以忽略你的 `/robots.txt`. 尤其是扫描网站安全漏洞和收集邮箱的恶意爬虫, 要特别注意.

* `/robots.txt` 是一个公开的文件, 任何人都能知道你网站的哪个部分不想让网络爬虫访问.

所以, 不要试图通过 `/robots.txt` 来隐藏信息.


## 详细介绍

`/robots.txt` 是一个事实标准, 它不属于任何标准制定机构. 这有两个历史描述文件:

* [http://www.robotstxt.org/orig.html](the original 1994 A Standard for Robot Exclusion document)

* [http://www.robotstxt.org/norobots-rfc.txt](a 1997 Internet Draft specification A Method for Web Robots Control
)

以及两个补充资源:

[https://www.w3.org/TR/html4/appendix/notes.html#h-B.4.1.1](HTML 4.01 specification, Appendix B.4.1)

[https://en.wikipedia.org/wiki/Robots_exclusion_standard](kipedia - Robots Exclusion Standard)


### 放在哪

简单回答是: 网站的根目录.

`robots.txt` 是全小写的, 不能是 `Robots.TXT` .

### 规则怎么写

* 每个规则一行
 
* 同一组规则之间不能有空行

* 空行用来分割不同组的规则

* 不支持通配符和正则表达式 (`User-agent: *` 是特殊标注)

* 没有禁止的内容被视为可以访问

### 例子:

##### 禁止所有爬虫访问整个网站:

```text
User-agent: *
Disallow: /

```

##### 允许所有爬虫访问整个网站:

```text
User-agent: *
Disallow:

```

或 留空该文件或者不放置该文件.


##### 禁止所有爬虫访问网站的某些部分:

```text
User-agent: *
Disallow: /cgi-bin/
Disallow: /tmp/
Disallow: /junk/
```

##### 禁止某个爬虫访问:

```text
User-agent: BadBot
Disallow: /
```

##### 只允许某爬虫访问:

```text
User-agent: Google
Disallow:

User-agent: *
Disallow: /
```

##### 排除一个文件以外的其他文件:

这当前有点尴尬, 因为没有 "允许" 字段.
简单的方法是将所有禁止的文件放入一个单独的目录, 比如“stuff”, 并将那个允许访问的文件放在该目录的上一层:

```text
User-agent: *
Disallow: /~joe/stuff/
```

或者明确禁止每个文件:

```text
User-agent: *
Disallow: /~joe/junk.html
Disallow: /~joe/foo.html
Disallow: /~joe/bar.html
```







