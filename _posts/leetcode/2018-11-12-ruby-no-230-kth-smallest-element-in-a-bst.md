---
layout: post
title:  LeetCode Ruby No.230 kth-smallest-element-in-a-bst  
date:   2018-11-12
categories: algorithm
---

前提条件是有效的BST, 而且 1<=k<=nums , 所以不用考虑特殊情况.

BST的性质是左节点小于根节点, 右节点大于根节点, 没有重复元素.

题目要求查找第K个最小的元素, 即使用中序遍历即可. 

利用Ruby的实例变量可以很容易的控制退出条件.


```ruby

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {TreeNode} root
# @param {Integer} k
# @return {Integer}
def kth_smallest(root, k)
  @k = k
  @result = nil
  @counter = 0

  preorder(root)

  @result
end

def preorder(root)
  return nil if root.nil? || !@result.nil?

  preorder(root.left) if root.left

  @counter += 1
  if @counter == @k
    @result = root.val
  end

  preorder(root.right) if root.right
end

```