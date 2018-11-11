---
layout: post
title:  LeetCode Ruby No.106 construct-binary-tree-from-inorder-and-postorder-traversal  
date:   2018-11-11
categories: algorithm
---

注意分割的边界:

从后序中取最后一个为根节点, 找该节点在中序中的位置.

中序中, 该位置左侧为左数, 右侧为右树, 均不包含该节点.

后序中, 最后一位已经确认, 分界点属于右树(left-right-root).


```ruby

# Definition for a binary tree node.
# class TreeNode
#     attr_accessor :val, :left, :right
#     def initialize(val)
#         @val = val
#         @left, @right = nil, nil
#     end
# end

# @param {Integer[]} inorder
# @param {Integer[]} postorder
# @return {TreeNode}
def build_tree(inorder, postorder)
  post_i = postorder.last
  return nil if post_i.nil?
  
  node = TreeNode.new(post_i)
  i = inorder.index(post_i)
  
  node.left = build_tree(inorder[0...i], postorder[0...i])
  node.right = build_tree(inorder[i+1..-1], postorder[i...-1])
  
  node
end

```