---
layout: post
title:  LeetCode Ruby No.1 two-sum  
date:   2018-11-06
categories: algorithm
---

## 暴力法

> Timeout

```ruby
# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer[]}
def two_sum(nums, target)
  nums.size.times do |i|
    nums.size.times do |j|
      next if i == j

      return [i, j] if nums[i] + nums[j] == target
    end
  end
end

# puts two_sum([1, 2, 7, 11, 15], 9)

```

## 先存 hash 再反查 

既然 O(n2) 会超时, 就用空间换时间, 利用hash反向存储item和index的对应关系.

可以边存边寻找匹配数字, 如果找到就立即返回, 可以进一步减少一次遍历.

hint: 输入数据并不保证没有重复, 为应对 `([3,3], 6)` hash_tab 里应该存所有的索引.

> AC

```ruby

# @param {Integer[]} nums
# @param {Integer} target
# @return {Integer[]}

def two_sum(nums, target)
  hash_tab = {} # [2, [0, ]]

  nums.each_index do |i|
    num = nums[i]
    hash_tab[num] ||= []
    hash_tab[num] << i

    # 需要的配对的数字
    need_num = target - num
    index_arr = hash_tab[need_num]
    next if index_arr.nil?

    index_arr.each do |need_num_index|
      next if need_num_index == i
      return [need_num_index, i]
    end

  end

  raise "not found"
end

# ans = two_sum([3, 3], 7)
# puts ans

```