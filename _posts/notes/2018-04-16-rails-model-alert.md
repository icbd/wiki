---
layout: post
title:  Rails 用 Modal 替代 alert
date:   2018-04-16
categories: Rails
---

> app/views/shared/_modal_sample.html.rb

```
<!--alert sample message-->
<!--when hidden.bs.modal, remove this element point-->
<div class="modal fade modal-sample" tabindex="-1" role="dialog">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Secretube</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <%= object %>
      </div>
    </div>
  </div>
</div>
```

> create.js.erb

```
//sth else

$("#modal_container").html("<%= j render("shared/modal_sample", object: @hint) %>");
$("#modal_container > .modal").modal("show");
```

> application.js

```
// sth else

$(function () {
    // avoid model repeat
    $("#modal_container").on('hidden.bs.modal', function () {
        $(this).removeData('bs.modal');
        $(this).empty();
    })
});

```



