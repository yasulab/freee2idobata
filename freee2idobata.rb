#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rss'
require 'idobata'
require 'pry'

Idobata.hook_url = ENV['IDOBATA_END']

msg = ""
# Flush cache RSS before downloading
`curl -H 'Pragma: no-cache' -L www.freee.co.jp/blog/feed`

rss = RSS::Parser.parse("http://www.freee.co.jp/blog/feed")

# NOTE: Heroku Scheduler's frequency should be set to "Every 10 minutes"
articles = rss.items.select do |item|
  #(Time.now - item.date) / 60 <= 10000 # for debugging
  (Time.now - item.date) / 60 <= 10
end

#binding.pry

msg << articles.map {|a|
  p "<a href='#{a.link}'>#{a.title}</a> by <span class='label label-info'>freee</span><br /> <b>#{a.description}<b/>"
}.join("<br/>")


Idobata::Message.create(source: msg, format: :html) unless msg.empty?
