---
layout: post
title:  LeetCode Ruby No.145 binary-tree-postorder-traversal  
date:   2018-11-11
categories: algorithm
---

## 迭代法

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
def postorder_traversal(root)
      result = []
  return result unless root

  result += postorder_traversal(root.left) if root.left
  result += postorder_traversal(root.right) if root.right
  result << root.val

  result 
end

```

## 循环法

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
def postorder_traversal(root)
  result = []
  buffer = []
  return result unless root
  
  while !root.nil? or !buffer.empty?
    while root
      buffer.push root.right if root.right
      buffer.push root
      root = root.left
    end
    
    root = buffer.pop
    if root.right && root.right == buffer.last
      temp = root
      root = buffer.pop
      buffer.push temp
    else
      result << root.val
      root = nil
    end
  end
  
  result
end
```