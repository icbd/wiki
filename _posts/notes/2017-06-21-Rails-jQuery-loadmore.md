---
layout: post
title:  Rails jQuery加载更多
date:   2017-06-21
categories: Rails
---

通过HTML标签中的data-暂存接口信息和分页信息, 做到js代码可复用.

html:

```
      <div id="user_main_channel_flow_container"></div>
      <a href="javascript:;" data-next-page data-url="<%= ajax_channels_user_path(params[:id] || current_user) %>"
         data-container="#user_main_channel_flow_container" class="more-btn btn btn-default">更多</a>
```

jQuery:

```
// 加载更多
$('.more-btn').click(function () {
    var $this = $(this);
    var nextPage = $this.data('next-page') || 1;
    if (nextPage == -1) {
        $this.addClass('nomore');
        $this.attr('disabled', 'disabled');
        return;
    }

    $.ajax({
        url: $this.data('url'),
        dataType: 'json',
        data: {
            page: nextPage
        },
        beforeSend: function () {
            $this.data('ori-html', $this.html()).html('Loading...');
        },
        success: function (data) {
            $this.data('next-page', data.msg.next_page);
            if (data.msg.next_page == -1) {
                $this.addClass('nomore');
                $this.attr('disabled', 'disabled');
            }

            $($this.data('container')).append(data.msg.html);
        },
        complete: function () {
            $this.html($this.data('ori-html'));
        }
    })
}).trigger('click');
```

Rails:

```
  def ajax_channels
    if params[:id].nil?
      user = current_user
    else
      user = User.find(params[:id])
    end

    page = Integer(params[:page]) rescue 1
    per_page = Integer(params[:per_page]) rescue 5

    @channels = Channel.where("user_id" => user.id)
                    .offset((page - 1)*per_page).limit(per_page)
                    .order("id desc")
    return render json: {
        status: :ok,
        msg: {
            html: render_to_string(layout: false),
            next_page: (@channels.blank? ? -1 : (page + 1))
        }
    }
  end
```

