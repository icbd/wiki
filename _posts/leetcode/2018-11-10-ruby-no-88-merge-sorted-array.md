---
layout: post
title:  LeetCode Ruby No.88 merge-sorted-array  
date:   2018-11-10
categories: algorithm
---

```ruby

# @param {Integer[]} nums1
# @param {Integer} m
# @param {Integer[]} nums2
# @param {Integer} n
# @return {Void} Do not return anything, modify nums1 in-place instead.
def merge(nums1, m, nums2, n)
  tail_1 = m - 1
  tail_2 = n - 1

  # from tail to header
  cursor = n + m - 1
  (n + m - 1).step(0, -1) do |i|
    cursor = i
    break if tail_1 < 0 || tail_2 < 0
    if nums1[tail_1] > nums2[tail_2]
      nums1[i] = nums1[tail_1]
      tail_1 -= 1
    else
      nums1[i] = nums2[tail_2]
      tail_2 -= 1
    end
  end


  # 处理num2最后的一段
  # 如果num1剩下的话, 它自己本身就是有序的
  if cursor >= 0 and tail_2 >= 0
    cursor.step(0, -1) do |i|
      nums1[i] = nums2[tail_2]
      tail_2 -= 1
    end
  end

  nums1
end

# p merge [1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3
# p merge [0], 0, [1], 1
# p merge [4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3

```

LeetCode 允许写辅助方法和辅助类, 逻辑稍微清楚一点

```ruby

class Num
  def initialize(arr, len)
    @arr = arr
    @len = len
  end

  def pop
    index = @len - 1
    if index >= 0
      @len -= 1
      @arr[index]
    else
      nil
    end
  end

  def back
    @len += 1
  end
end

# @param {Integer[]} nums1
# @param {Integer} m
# @param {Integer[]} nums2
# @param {Integer} n
# @return {Void} Do not return anything, modify nums1 in-place instead.
def merge(nums1, m, nums2, n)
  obj1 = Num.new(nums1, m)
  obj2 = Num.new(nums2, n)

  (n + m - 1).step(0, -1) do |index|
    num_of_obj1 = obj1.pop
    num_of_obj2 = obj2.pop

    if num_of_obj1.nil? or num_of_obj2.nil?
      nums1[index] = num_of_obj1 || num_of_obj2
    else
      if num_of_obj1 > num_of_obj2
        nums1[index] = num_of_obj1
        obj2.back
      else
        nums1[index] = num_of_obj2
        obj1.back
      end
    end
  end

  nums1
end

# p merge [1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3
# p merge [0], 0, [1], 1
# p merge [4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3

```