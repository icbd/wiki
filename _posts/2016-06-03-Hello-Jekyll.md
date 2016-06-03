---
layout: post
title:  "Hello Jekyll!"
date:   2016-06-03
categories: 工具
--------------

# Hello Jekyll
环境: OS X 10.11.5

## 安装
OS X 自带ruby和gem, 由gem安装Jekyll.
由于EI Captain的限制 `/usr/bin`的写入, 需要自己指定安装目录.
`$ sudo gem install jekyll -n ~/devel/gems/jekyll/ `
`$ sudo ln -s ~/devel/gems/jekyll/jekyll /usr/local/bin/jekyll`

## 本地运行
```
$ jekyll -v
jekyll 3.1.6

$ jekyll new wiki
$ cd wiki 
$ jekyll server

```

## Github.io
1. 先编辑 wiki/_config.yml
2. 初始化Git仓库
```
$ git init
$ git add . 
$ git commit -m 'init new wiki'
```
3. 在github新建`wiki`项目
4. push到 gh-pages 分支
```
$ git remote add origin https://github.com/icbd/wiki.git
$ git push -u  origin gh-pages
```
5. 查看 https://icbd.github.io/wiki/


