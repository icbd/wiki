---
layout: post
title:  LeetCode Ruby No.144 binary-tree-preorder-traversal  
date:   2018-11-10
categories: algorithm
---

# 递归法

```ruby

# @param {TreeNode} root
# @return {Integer[]}
def preorder_traversal(root)
  result = []
  return result if root.nil?

  result << root.val
  result += preorder_traversal(root.left) if root.left
  result += preorder_traversal(root.right) if root.right

  result
end

```

# 栈记录法

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
# @return {Integer[]}
def preorder_traversal(root)
  # 先序遍历, root, left, right

  result = []
  buffer = [] # 访问路径的栈

  buffer.push(root) if root

  while node = buffer.pop
    result << node.val
    # 不用的先pop进去
    buffer.push(node.right) if node.right
    buffer.push(node.left) if node.left
  end

  result
end

```