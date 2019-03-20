---
layout: post
title:  Rails 处理类名
date:   2019-03-20
categories: Rails
---

Rails 中, 

目录和文件名都是小写的蛇底式(SnakeCase), 模块名和类名本身是常量, 为驼峰式(CamelCase).

Rails 项目的目录会自动形成模块, 之间用 `::` 连接. 

重构的时候经常要处理字符串的格式和其对应的常量.

### snakecase => camelcase

情景: 通过路径和文件名查找类和模块. 

不处理单复数.

```ruby
'active_record'.camelize                # => "ActiveRecord"
'active_record'.camelize(:lower)        # => "activeRecord"
'active_record/errors'.camelize         # => "ActiveRecord::Errors"
'active_record/errors'.camelize(:lower) # => "activeRecord::Errors"
```

 `camelcase` 是 `camelize` 的别名.
 
### camelcase => snakecase

情景: 已知类名找对应的 FactoryBot 的定义.

不处理单复数.

```ruby
"ActiveRecord::Errors".underscore # => "active_record/errors"
"LineItem".underscore             # => "line_item"
```

注意, 并不能通过常量名推定出该常量的定义文件, 该方法只会简单的把 `::` 替换为 `/`.

```ruby
'ActiveSupport::EncryptedFile::MissingContentError'.underscore 
  # => "active_support/encrypted_file/missing_content_error"
```

实际定义位置:

```ruby
# activesupport-5.2.2.1/lib/active_support/encrypted_file.rb
module ActiveSupport
  class EncryptedFile
    class MissingContentError < RuntimeError
      def initialize(content_path)
        super "Missing encrypted content file in #{content_path}."
      end
      
      # ...
    end
  end 
end     
```

### 删除常量名中的模块名

截断常量中的模块名, 仅保留最后一个部分.

```ruby
'ActiveSupport::Inflector::Inflections'.demodulize # => "Inflections"
'Inflections'.demodulize                           # => "Inflections"
'::Inflections'.demodulize                         # => "Inflections"
''.demodulize                                      # => ''
```

### 删除常量名中的后缀

截断常量最后的模块名/类名, 只保留之前的模块路径.

```ruby
'Net::HTTP'.deconstantize   # => "Net"
'::Net::HTTP'.deconstantize # => "::Net"
'String'.deconstantize      # => ""
'::String'.deconstantize    # => ""
''.deconstantize            # => ""
'ActiveSupport::Inflector::Inflections'.deconstantize
  # => "ActiveSupport::Inflector"

```


### table name => model name

处理最后一个类的单复数, 不处理目录的单复数. 

返回值为字符串.

```ruby
'line_item'.classify        # => "LineItem"
'line_items'.classify       # => "LineItem"
'china/line_items'.classify # => "China::LineItem"
'goods/line_items'.classify # => "Goods::LineItem"
```

### model name => table name

把字符串处理成 snakecase, 最后一段变复数, `::` 替换为 `/`.

```ruby
'RawScaledScorer'.tableize # => "raw_scaled_scorers"
'ham_and_egg'.tableize     # => "ham_and_eggs"
'fancyCategory'.tableize   # => "fancy_categories"

'Raw::ScaledScorer'.tableize # => "raw/scaled_scorers"
```

### String => Constant

由处理好的字符串来查找对已经的常量, 找不到即抛 `NameError`.

`safe_constantize` 在找不到常量的时候返回 `nil` .

大小写敏感.

```ruby
'Module'.constantize  # => Module
'Class'.constantize   # => Class
'blargle'.constantize # => NameError: wrong constant name blargle

'ActiveSupport::EncryptedFile::MissingContentError'.constantize
  # => ActiveSupport::EncryptedFile::MissingContentError

'ActiveSupport'.safe_constantize  # => ActiveSupport
'xxx'.safe_constantize            # => nil
```

### snakecase => dasherize

下划线替换为横杠.

```ruby
'puni_puni'.dasherize # => "puni-puni"
```

## Reference

[https://api.rubyonrails.org/classes/String.html](https://api.rubyonrails.org/classes/String.html)
