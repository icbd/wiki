---
layout: post
title:  LeetCode Ruby No.21 merge-two-sorted-lists  
date:   2018-11-07
categories: algorithm
---

```ruby

# Definition for singly-linked list.
# class ListNode
#     attr_accessor :val, :next
#     def initialize(val)
#         @val = val
#         @next = nil
#     end
# end

# @param {ListNode} l1
# @param {ListNode} l2
# @return {ListNode}
def merge_two_lists(l1, l2)
  # 结点的含义, 不仅表示当前结点对象, 还表示从该结点开始, 直至遍历到next为nil的一条链表.
  #
  # 头结点, 该头结点本身不是链表的一部分
  header = ListNode.new(:header)
  # 结果链表
  result_list_node = header

  loop do
    break if l1.nil? or l2.nil?

    if l1.val <= l2.val
      result_list_node.next = l1
      l1 = l1.next
    else
      result_list_node.next = l2
      l2 = l2.next
    end


    # 光标移位
    result_list_node = result_list_node.next
    # 截断
    result_list_node.next = nil
  end

  # 剩余片段拼接
  result_list_node.next = l1 || l2
  # 头结点之后的链表真身
  header.next
end

```