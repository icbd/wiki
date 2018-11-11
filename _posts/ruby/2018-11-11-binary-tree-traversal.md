---
layout: post
title:  二叉树遍历 with Ruby  
date:   2018-11-11
categories: algorithm Ruby
---

# 前序遍历 preorder traversal

- root
- left
- right

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
def preorder_traversal(root)
  result = []
  return result unless root

  result << root.val
  result += preorder_traversal(root.left) if root.left
  result += preorder_traversal(root.right) if root.right

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
def preorder_traversal(root)
  result = []
  buffer = []

  buffer.push root if root
  while !root.nil? or !buffer.empty?
    if root = buffer.pop
      result << root.val 
      buffer.push root.right if root.right
      buffer.push root.left if root.left
    end
  end

  result
end

```


# 中序遍历 inorder traversal

- left
- root
- right

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
def inorder_traversal(root)
  result = []
  return result unless root

  result += inorder_traversal(root.left) if root.left
  result << root.val
  result += inorder_traversal(root.right) if root.right

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
def inorder_traversal(root)
  result = []
  buffer = []
  
  while !root.nil? or !buffer.empty?
    while root
      buffer.push root
      root = root.left
    end
    
    if root = buffer.pop
      result << root.val
      root = root.right
    end
  end

  result 
end

```


# 后序遍历 postorder traversal

- left
- right
- root

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