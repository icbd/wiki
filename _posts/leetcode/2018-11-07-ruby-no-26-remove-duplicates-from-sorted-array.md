---
layout: post
title:  LeetCode Ruby No.26 remove-duplicates-from-sorted-array  
date:   2018-11-07
categories: algorithm
---

```ruby

# @param {Integer[]} nums
# @return {Integer}
def remove_duplicates(nums)
  # 当输入为空数组的时候, 直接返回0
  return 0 if nums.empty?

  # 光标位, 依次顺序向后
  cursor = 1
  # 待插入元素的位置标记
  location = 1

  (nums.size - 1).times do
    nums[location] = nums[cursor] if location != cursor

    if nums[cursor] == nums[location - 1]
      # 遇到重复元素, 插入为就不再移动
      location += 0
    else
      location += 1
    end
    # 光标每次都移动
    cursor += 1
  end

  location
end


# arr = [0, 0, 1, 1, 1, 2, 2, 3, 3, 4]
# arr = [1,1,2]
# p len = remove_duplicates(arr)
# p arr[0...len]


```