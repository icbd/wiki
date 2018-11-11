---
layout: post
title:  LeetCode Ruby No.101 symmetric-tree
date:   2018-11-11
categories: algorithm
---

类比 No.100 判断相同的树

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
# @return {Boolean}
def is_symmetric(root)
  return true if root.nil?
  
  compare_func(root.left, root.right)
end

def compare_func(p, q)
  return true if p.nil? && q.nil?
  
  if p && q && (p.val == q.val)
    compare_func(p.left, q.right) && compare_func(p.right, q.left)
  else
    false
  end
end

```