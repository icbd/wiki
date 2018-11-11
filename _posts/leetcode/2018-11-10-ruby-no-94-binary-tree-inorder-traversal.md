---
layout: post
title:  LeetCode Ruby No.94 binary-tree-inorder-traversal  
date:   2018-11-10
categories: algorithm
---

# 二叉树中序遍历

# 递归法

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
def inorder_traversal(root)
  # 中序遍历: left, root, right
  
  result = []
  return result if root.nil?
  
  result += inorder_traversal(root.left) if root.left
  result << root.val
  result += inorder_traversal(root.right) if root.right
  
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
def inorder_traversal(root)
  # 中序遍历: left, root, right
  
  result = []
  buffer = []
  
  until buffer.empty? and root.nil? do
    while root
      buffer.push(root)
      root = root.left 
    end
    
    root = buffer.pop
    result << root.val
    root = root.right
  end

  result
end

```