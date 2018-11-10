---
layout: post
title:  LeetCode Ruby No.100 same-tree  
date:   2018-11-10
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

# @param {TreeNode} p
# @param {TreeNode} q
# @return {Boolean}
def is_same_tree(p, q)
  return true if p.nil? and q.nil?

  if p && q && (p.val == q.val)
    return is_same_tree(p.left, q.left) && is_same_tree(p.right, q.right)
  else
    false
  end
end

```