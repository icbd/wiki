---
layout: post
title:  Ruby Pathname
date:   2019-03-20
categories: Ruby
---

Pathname表示文件系统上的文件或目录的名称, 但不表示文件本身.

路径名取决于操作系统, 但实验上支持非Unix路径名.

路径名可以是相对的或绝对的.

文件名是否对应真实文件并不重要, 直到你尝试使用该文件, 他才真正读取文件, 如果文件不存在则抛出异常: `Errno::ENOENT`.

路径名是不可变的. 它没有破坏性更新的方法.

这个类的目标是以比Ruby标准提供的更简洁的方式操作文件路径信息. 以下示例说明了不同之处.

File，FileTest以及Dir和FileUtils中的一些功能都以自然的方式包含在内. 

它本质上是其他方法的包装，也提供了一些新方法.

### Using Pathname

```ruby
require 'pathname'
pn = Pathname.new("/usr/bin/ruby")
size = pn.size              # 27662
isdir = pn.directory?       # false
dir  = pn.dirname           # Pathname:/usr/bin
base = pn.basename          # Pathname:ruby
dir, base = pn.split        # [Pathname:/usr/bin, Pathname:ruby]
data = pn.read
pn.open { |f| _ }
pn.each_line { |line| _ }
```

### Using standard Ruby

```ruby
pn = "/usr/bin/ruby"
size = File.size(pn)        # 27662
isdir = File.directory?(pn) # false
dir  = File.dirname(pn)     # "/usr/bin"
base = File.basename(pn)    # "ruby"
dir, base = File.split(pn)  # ["/usr/bin", "ruby"]
data = File.read(pn)
File.open(pn) { |f| _ }
File.foreach(pn) { |line| _ }
```

### Special Feature

```ruby
p1 = Pathname.new("/usr/lib")   # Pathname:/usr/lib
p2 = p1 + "ruby/1.8"            # Pathname:/usr/lib/ruby/1.8
p3 = p1.parent                  # Pathname:/usr
p4 = p2.relative_path_from(p3)  # Pathname:lib/ruby/1.8
pwd = Pathname.pwd              # Pathname:/home/gavin
pwd.absolute?                   # true
p5 = Pathname.new "."           # Pathname:.
p5 = p5 + "music/../articles"   # Pathname:music/../articles
p5.cleanpath                    # Pathname:articles
p5.realpath                     # Pathname:/home/gavin/articles
p5.children                     # [Pathname:/home/gavin/articles/linux, ...]
```

## Reference

[http://ruby-doc.org/stdlib-2.6.2/libdoc/pathname/rdoc/Pathname.html](http://ruby-doc.org/stdlib-2.6.2/libdoc/pathname/rdoc/Pathname.html)