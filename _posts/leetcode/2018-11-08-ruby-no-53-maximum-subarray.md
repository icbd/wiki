---
layout: post
title:  LeetCode Ruby No.53 maximum-subarray  
date:   2018-11-08
categories: algorithm
---

# DP

```ruby

# @param {Integer[]} nums
# @return {Integer}
def max_sub_array(nums)
  finally_sum = nums.shift
  pre_list_sum = finally_sum

  nums.each do |num|
    # 加入之前的列表, 还是自己新开一个
    pre_list_sum = [pre_list_sum + num, num].max

    # 更新结果
    finally_sum = [pre_list_sum, finally_sum].max
  end

  finally_sum
end

# p max_sub_array [-2, 1, -3, 4, -1, 2, 1, -5, 4]


```

# 分治

```ruby

# @param {Integer[]} nums
# @return {Integer}
def max_sub_array(nums)
  divide(nums)
end


# 分治
# 总共三种情况:
# 1) mid 元素左边(不包含mid)
# 2) mid 元素右边(不包含mid)
# 3) 包含 mid 元素, 从mid向两边延展
def divide(nums)
  return nums[0] if nums.size == 1
  return [nums[0], nums[1], nums[0] + nums[1]].max if nums.size == 2

  # 以下情况: size >=3
  #
  #  中间元素的 cursor
  mid_index = nums.size / 2
  # 1)
  max_sum_of_left = divide(nums[0..mid_index - 1])
  # 2)
  max_sum_of_right = divide(nums[mid_index + 1..-1])
  # 3)
  # 初始化从中间值到左边头的最大值
  max_sum_of_mid = nums[mid_index]
  temp_sum = nums[mid_index]
  nums[0...mid_index].reverse_each do |item|
    temp_sum += item
    if temp_sum > max_sum_of_mid
      max_sum_of_mid = temp_sum
    end
  end
  # 向右延伸
  temp_sum = max_sum_of_mid
  nums[(mid_index + 1)..-1].each do |item|
    temp_sum += item
    if temp_sum > max_sum_of_mid
      max_sum_of_mid = temp_sum
    end
  end

  # p [max_sum_of_left, max_sum_of_right, max_sum_of_mid]
  [max_sum_of_left, max_sum_of_right, max_sum_of_mid].max
end

# p divide([1, 2, 3])
# p max_sub_array [-2,1,-3,4,-1,2,1,-5,4]
 

```