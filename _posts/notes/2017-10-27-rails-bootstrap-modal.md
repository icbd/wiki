---
layout: post
title:  在Rails中使用Bootstrap的Modal
date:   2017-10-27
categories: Rails
---

> ruby 2.3.4p301 (2017-03-30 revision 58214) [x86_64-darwin16]
> Rails 5.1.4

![rails-bootstrap-modal](/wiki/wiki/rails-bootstrap-modal.png)

## 删除功能:

```
<%= link_to 'Delete', machine,
            method: :delete,
            data: {confirm: "Delete #{machine.ip} ?"},
            remote: true, 'data-target' => 'delete_machine' %>
```

在普通的 `link_to` 中加入 `remote: true`, 使其转化为一个 Ajax 提交.

点击删除按钮, 会收到一个 DELETE 动作的请求,:

```
Started DELETE "/machines/30" for 127.0.0.1 at 2017-10-27 17:20:42 +0800
Processing by MachinesController#destroy as JS
  Parameters: {"id"=>"30"}
```

```
  # DELETE
  def destroy
    machine = Machine.find(params['id'])

    if machine.destroy
      @status = true
    else
      @status = false
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: dashboard_url) }
      format.js
    end
  end
```

处理完删除逻辑后, 渲染 `destroy.js.erb` :

```
$("[data-target='delete_machine']").bind('ajax:success', function () {

    if (<%= @status %>) {
        $(this).parents('tr').eq(0).hide();
    } else {
        alert("Delete Failed");
    }
});
```

`@status` 是 Controller 中传过来的, 表示删除操作是否成功. 如果是, 则隐藏显示对应的 tr 元素, 如果否就 alert .
这段js在后端渲染完成后返回给页面执行.

## 新增一条

```
    <%= link_to new_machine_path,
                id: "create_machine",
                class: "pull-right btn btn-primary btn-xs",
                remote: true do %>

        <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>
        New Machine
    <% end %>
```

按钮链接指向 new_machine_path 而且使用 remote 方式. Controller 中 new 处理这个 GET 请求, 来展示新建所需的表单.

new 动作渲染 `new.js.erb` 模板:

```
<% provide(:modal_title, "New Machine") %>

$('#mainModal').html("<%= j render 'machines/modal_form' %>");
$('#mainModal').modal('show');
```

`modal_form.html.erb` 是表单主体部分:

```
<% content_for :modal_body do %>

    <%= form_for(@machine) do |f| %>
        <%= render 'shared/error_messages', object: f.object %>

        <% if @machine.id %>
            <%= f.label :id %>
            <%= f.text_field :id, class: "form-control", disabled: "disabled" %>
        <% end %>

        <%= f.label :ip %>
        <%= f.text_field :ip, class: "form-control" %>

        <%= f.label :login_name %>
        <%= f.text_field :login_name, class: "form-control" %>

        <%= f.label :login_password %>
        <%= f.text_field :login_password, class: "form-control" %>

        <%= f.label :memo %>
        <%= f.text_area :memo, class: "form-control" %>

        <label for="machine_is_serving">
          <%= f.check_box(:is_serving) %> Is Serving?
        </label>

    <% end %>

<% end %>


<%= render("shared/modal") %>
```

`shared/_modal.html.erb` 是一个通用的 Bootstrap Modal模板:

```
<div class="modal-dialog">
  <div class="modal-content">

    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal">
        <span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
      <h4 class="modal-title" id="mainModalLabel">
        <%= yield :modal_title if content_for? :modal_title %></h4>
    </div>

    <div class="modal-body" id="modalBody">
      <%= yield :modal_body if content_for? :modal_body %>
    </div>

    <% if content_for? :modal_footer %>
        <%= yield :modal_footer %>
    <% else %>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal"><%= t(:cancel) %></button>
          <button type="button" class="btn btn-primary" id="modalFooterBtn">
            <% if content_for? :modal_ok %>
                <%= yield :modal_ok %>
            <% else %>
                <%= t(:ok) %>
            <% end %>
          </button>
        </div>
    <% end %>

  </div>
</div>
<script>
    // 代提交
    $('#modalFooterBtn').click(function () {
        $("#modalBody").find("form").ajaxSubmit();
//        $('#mainModal').modal('hide');
    });
</script>
```

render 前使用了 j 方法, 是 escape_javascript 的别名, 把 html 代码清洗为合法的可用于jS的字符串.

