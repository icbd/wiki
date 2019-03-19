---
layout: post
title:  Thor Basic
date:   2019-03-19
categories: Ruby
---

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'

# Cbdcli, terminal tools by Ruby
class Cbdcli < Thor
  desc 'Time now', 'with time zone'
  option :zone
  def now
    tz_name = options[:zone] || 'Asia/Shanghai'
    with_time_zone(tz_name: tz_name) do
      p Time.now
    end
  end

  private

  def with_time_zone(tz_name:)
    prev_tz = ENV['TZ']
    ENV['TZ'] = tz_name
    yield
  ensure
    ENV['TZ'] = prev_tz
  end
end

Cbdcli.start(ARGV)

```

```bash
./cbdcli --help

./cbdcli now
#2019-03-19 15:55:04 +0800

./cbdcli now --zone America/New_York
#2019-03-19 03:55:26 -0400

```

### Reference

[http://whatisthor.com/](http://whatisthor.com/)