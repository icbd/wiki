---
layout: post
title:  first line of unix-like file
date:   2018-02-05
categories: notes
---

在 Unix-like 的文件开头使用 `#!/Users/cbd/.rvm/rubies/ruby-2.3.4/bin/ruby` 可以指定本文件通过该解释器执行.
但是每台机器的ruby安装目录不一定一样, 为了找到ruby的安装路径应该使用 `env` .

```
$ /usr/bin/env ruby -v
ruby 2.3.4p301 (2017-03-30 revision 58214) [x86_64-darwin16]
```

> 文件首行

```
#!/usr/bin/env ruby
```

