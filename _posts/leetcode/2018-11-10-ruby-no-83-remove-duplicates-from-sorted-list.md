---
layout: post
title:  LeetCode Ruby No.83 remove-duplicates-from-sorted-list 
date:   2018-11-10
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

# @param {ListNode} head
# @return {ListNode}
def delete_duplicates(head)
  cursor = head

  while cursor and cursor.next
    if cursor.next.val == cursor.val
      cursor.next = cursor.next.next
    else
      cursor = cursor.next
    end
  end

  head
end


```