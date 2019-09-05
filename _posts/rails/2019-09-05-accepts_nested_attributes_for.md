---
layout: post
title:  Rails accepts_nested_attributes_for
date:   2019-09-05
categories: Rails
---

当创建一连串关联的对象的时候, `accepts_nested_attributes_for` 会帮我们简化很多工作.
这里使用 Rails 的 `--api` 模式, 略去 `accepts_nested_attributes_for` 跟 view 里表单的配合的部分.

嵌套属性允许你通过父级来保存相关的记录. 这个功能默认是关闭的, 可以使用类方法 `accepts_nested_attributes_for` 来开启.

```bash
rails new nested_attributes_demo --api
bundle install
```
 

### models

```ruby
# == Schema Information
#
# Table name: orders
#
#  id          :integer          not null, primary key
#  total_price :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  address_id  :integer
#

class Order < ApplicationRecord
  has_many :line_items
  has_one :memo
  belongs_to :address

  accepts_nested_attributes_for :line_items
  accepts_nested_attributes_for :memo
  accepts_nested_attributes_for :address
end

```

```ruby
# == Schema Information
#
# Table name: line_items
#
#  id         :integer          not null, primary key
#  name       :string
#  price      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#

class LineItem < ApplicationRecord
  belongs_to :order

  validates :price, presence: true
end

```

```ruby
# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  city       :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Address < ApplicationRecord
  has_many :orders
end

```

```ruby
# == Schema Information
#
# Table name: memos
#
#  id         :integer          not null, primary key
#  detail     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#

class Memo < ApplicationRecord
end

```

## 基本声明

```ruby
  has_one :memo
  accepts_nested_attributes_for :memo
```

`一对一` 的关系: `accepts_nested_attributes_for` 后要用单数来声明, 会自动生成 `memo_attributes=` 的 `写方法` .


```ruby
  has_many :line_items
  accepts_nested_attributes_for :line_items
```

`一对多` 的关系: `accepts_nested_attributes_for` 后要用复数来声明, 会自动生成 `line_items_attributes=` 的 `写方法` .

```ruby
  belongs_to :address
  accepts_nested_attributes_for :address
```

`多对一` 的关系: `accepts_nested_attributes_for` 后要用单数来声明, 会自动生成 `address_attributes=` 的 `写方法` .


## 基本用法

```ruby
params = { order: { total_price: 100,
                    memo_attributes: { detail: '2019-09-05' },
                    address_attributes: { city: 'Shanghai', zip: '200000' },
                    line_items_attributes: [
                      { name: 'l1', price: 10 },
                      { name: 'l2', price: 60 },
                      { name: 'l3', price: 30 }
                    ] } }

order = Order.create(params[:order])
```

如此会创建 order 以及相关的 memo 和 address 和 一系列 line_items .


```ruby
order.update(total_price: 120, line_items_attributes: [{name: 'l_new', price: 20}])
```
更新时携带嵌套信息, 而且嵌套信息不加 `id` 时, 会被认为是创建新的嵌套信息. 
上面就会插入一条新的 `l_new` 的 line_item 并把它归入该 order. 


```ruby
order.update(total_price: 115, line_items_attributes: [{id: 4, name: 'l_new', price: 15}])
```
更新时携带嵌套信息, 而且嵌套信息携带 `id` 时, 会被认为是更新id对应的嵌套信息. 
上面就会更新 `l_new` 的 line_item . 

如果提供的 line_item 的 id 并不属于该 order, 会报 `ActiveRecord::RecordNotFound` .

## 嵌套验证

```ruby
params = { order: { total_price: 100,
                    memo_attributes: { detail: '2019-09-05' },
                    address_attributes: { city: 'Shanghai', zip: '200000' },
                    line_items_attributes: [
                      { name: 'l1', price: 10 },
                      { name: 'l2', price: 60 },
                      { name: 'l3', price: 30 },
                      { name: 'l_orr', price: nil }
                    ] } }

order = Order.create params[:order]
order.errors.full_messages # ["Line items price can't be blank"]
```

当嵌套的任意对象存在验证失败, 都会让所有对象都创建不成功.

## 高级选项

### update_only

这个选项仅适用于 `一对一` 的关系.

```ruby
  has_one :memo
  accepts_nested_attributes_for :memo, update_only: true
```

```ruby
order.update(memo_attributes: {detail: 'updated memo'})
```

设置了这个选项之后, 就不用再传 memo 的 `id`, Rails 会先去找 order 对应的 memo , 然后再更新 memo .

> 默认没设置 `update_only` 的情况下, 会先把之前的 memo 的 order_id 置空, 然后插入一条新的 memo.

#### allow_destroy

默认情况下, 是不能通过嵌套属性来删除相关对象的. 

```ruby
accepts_nested_attributes_for :line_items, allow_destroy: true
```

```ruby
order.update(line_items_attributes: [{id: 3, _destroy: '1'}] )
```

设置 `allow_destroy` 为 true, 就可以使用 `_destroy` 来删除对应 id 的对象了.

`_destroy` 对应的 value 是什么不重要, 只要 if 判为真就可以 (只要不是 `nil` 和 `false` 就可以). 

注意: 待删对象的 id 必填.

### limit

默认情况下, order 并不会限制跟他一起创建多少个 line_item.

```ruby
accepts_nested_attributes_for :line_items, limit: 2
```

如果 line_item 的数目超出了 limit 限制, 会抛出 `ActiveRecord::NestedAttributes::TooManyRecords` .


### reject_if

```ruby
accepts_nested_attributes_for :line_items, reject_if: ->(attrs) { attrs[:price] > 50 }
```

当条件判断为 true 时, 即跳过这组属性. 上面的例子会忽略所有 price 大于 50 的line_item, 其他照旧创建.

## Reference

[https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html)