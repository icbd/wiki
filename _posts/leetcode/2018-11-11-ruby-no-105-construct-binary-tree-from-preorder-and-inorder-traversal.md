---
layout: post
title:  LeetCode Ruby No.105 construct-binary-tree-from-preorder-and-inorder-traversal  
date:   2018-11-11
categories: algorithm
---

注意分割的边界:

从先序中取第一个为根节点, 找该节点在中序中的位置.

中序中, 该位置左侧为左数, 右侧为右树, 均不包含该节点.

先序中, 第一位已经确认, 分界点属于左树(root-left-right).

```ruby

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {Integer[]} preorder
# @param {Integer[]} inorder
# @return {TreeNode}
def build_tree(preorder, inorder) 
  pre_i = preorder.first
  return nil if pre_i.nil?
  
  root = TreeNode.new(pre_i)
  # 先序的序号在中序数组中的位置
  i = inorder.index(pre_i)
  
  root.left = build_tree(preorder[1..i], inorder[0...i])
  root.right = build_tree(preorder[i+1..-1], inorder[i+1..-1])
  
  root
end

```