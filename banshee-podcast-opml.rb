#!/usr/bin/env ruby
#
# Script to generate OPML of podcasts from Banshee
#
# Thanks to
# http://blog.slashpoundbang.com/post/3385815540/how-to-generate-an-opml-file-with-ruby
#
# Public domain.

require 'rubygems'
require 'builder'
require 'sqlite3'

USER = ''
EMAIL = ''
DB_FILE = "#{ENV['HOME']}/.config/banshee-1/banshee.db"

class Podcast
  attr_reader :title, :description, :url

  def initialize title, description, url
    @title = title
    @description = description
    @url = url
  end
end

podcasts = []
db = SQLite3::Database.new(DB_FILE)
db.execute 'select * from PodcastSyndications' do |row|
  podcasts << Podcast.new(row[5], row[6], row[7])
end

xml = Builder::XmlMarkup.new(:target => STDOUT)
xml.instruct!
xml.opml(:version => 1.1) do
  xml.head do
    xml.title 'Podcasts'
    xml.dateCreated Time.new.httpdate
    xml.dateModified Time.now.httpdate
    xml.ownerName USER
    xml.ownerEmail EMAIL
  end
  xml.body do
    podcasts.each do |podcast|
      title = podcast.title
      xml.outline(:type => 'rss', :version => 'RSS', 
                  :description => podcast.description,
                  :title => title, :text => title, 
                   :xmlUrl => podcast.url)

    end
  end
end

