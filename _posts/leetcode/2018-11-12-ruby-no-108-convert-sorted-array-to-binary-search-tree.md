---
layout: post
title:  LeetCode Ruby No.108 convert-sorted-array-to-binary-search-tree  
date:   2018-11-12
categories: algorithm
---

```ruby

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {Integer[]} nums
# @return {TreeNode}
def sorted_array_to_bst(nums)
  return nil if nums.empty?

  if nums.length > 2
    # 中位数的索引
    mid_index = nums.length / 2
    root = TreeNode.new(nums[mid_index])
    root.left = sorted_array_to_bst(nums[0...mid_index])
    root.right = sorted_array_to_bst(nums[mid_index + 1..-1])
  elsif nums.length == 2
    root = TreeNode.new(nums[0])
    root.left = nil
    root.right = TreeNode.new(nums[1])
  elsif nums.length == 1
    root = TreeNode.new(nums[0])
  else
    return nil
  end

  root
end

```

把条件化简一下, 可以合并几种情况, 取 mid_index 为 `(nums.length - 1) / 2` .

```ruby

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {Integer[]} nums
# @return {TreeNode}
def sorted_array_to_bst(nums)
  return nil if nums.empty?
  
  mid_index = (nums.length - 1) / 2
  
  root = TreeNode.new(nums[mid_index])
  root.left = sorted_array_to_bst(nums[0...mid_index])
  root.right = sorted_array_to_bst(nums[mid_index + 1..-1])

  root
end

```