---
layout: post
title:  OptionParser
date:   2019-10-31
categories: Ruby
---

`OptionParser` 是 Ruby 的内置类, 用来处理命令行参数.

### 命令行示例:

```shell
git log --max-count=10
```

|git|log|--max-count|=|10|
|---|---|---|---|---|
|command|action|option| |argument|


### 参数模式:

* `--verbose`: Switch 长模式, 用来表示是否开启 `v` 对应的功能;

* `-v`: Switch 的短模式, 是长模式的别名, 效果同上;

* `-n NAME` or `--name NAME`: Flag 模式, 用来设置参数值;

* `-n=NAME` or `--name=NAME`: Flag 模式, 空格和等号可以互换, 效果同上, 只需要声明一种;

* `-l A,B,C` or `--list A,B,C`: Flag 模式, 参数为数组, 各个参数依照逗号分隔;


### Basic Demo:

```ruby
#!/usr/bin/env ruby

require 'optparse'

option_parser = OptionParser.new do |options|
  options.banner = '这是一个 OptionParser 示例.'

  options.on('--version', ' 版本')
  options.on('-v', '--verbose', '详情模式')
  options.on('-n', '--name NAME', '设置姓名')
  options.on('-a', '--age=AGE', '设置年龄')
  options.on('-l', '--list A,B,C', Array, '查看列表')
  options.on('--number=NUMBER', Numeric, '设置数值')
end

args = {}
option_parser.parse(ARGV, into: args)
p args
p ARGV

```

### 参数绑定:

绑定类型:

* Date – Anything accepted by Date.parse
* DateTime – Anything accepted by DateTime.parse
* Time – Anything accepted by Time.httpdate or Time.parse
* URI – Anything accepted by URI.parse
* Shellwords – Anything accepted by Shellwords.shellwords
* String – Any non-empty string
* Integer – Any integer. Will convert octal. (e.g. 124, -3, 040)
* Float – Any float. (e.g. 10, 3.14, -100E+13)
* Numeric – Any integer, float, or rational (1, 3.4, 1/3)
* DecimalInteger – Like Integer, but no octal format.
* OctalInteger – Like Integer, but no decimal format.
* DecimalNumeric – Decimal integer or float.
* TrueClass – Accepts '+, yes, true, -, no, false' and defaults as true
* FalseClass – Same as TrueClass, but defaults to false
* Array – Strings separated by ',' (e.g. 1,2,3)
* Regexp – Regular expressions. Also includes options.

### 参数提示

自动生成帮助命令 `-h` `--help`:

```bash
$ chmod +x client.rb
$ ./client -h
```

```text
这是一个 OptionParser 示例.
        --version                     版本
    -v, --verbose                    详情模式
    -n, --name NAME                  设置姓名
    -a, --age=AGE                    设置年龄
    -l, --list A,B,C                 查看列表
```

### 运行命令

```bash
$ ./client.rb -v -n Bob -l hi,hello --age 12 --number=3.14
```

```text
{:verbose=>true, :name=>"Bob", :list=>["hi", "hello"], :age=>"12", :number=>3.14}
["-v", "-n", "Bob", "-l", "hi,hello", "--age", "12", "--number=3.14"]
```
