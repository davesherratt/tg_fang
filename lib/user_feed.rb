#!/usr/bin/env ruby
Dir.chdir "/home/ec2-user/tg_fang/"
load 'Rakefile'
require 'active_record'
require 'telegram/bot'
require './app/models/user_feed'
require './app/models/update'
require 'open-uri'
configuration = YAML::load(IO.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(configuration)

file = "user_feed#{Time.now.to_i}"

open(file, 'wb') do |file|
  file << open('https://game.planetarion.com/botfiles/user_feed.txt').read
end
UserFeed.destroy_all
open(file) do |f|
  state = nil

  while (line = f.gets)
    case (state)
    when nil
      # Look for the line beginning with "FILE_SOURCES"
      if (line.match(/^Format/))
        state = :sources
      end
    when :sources
      # Stop printing if you hit something starting with "END"
      if (line.match(/^EndOfPlanetarionDumpFile/))
        state = nil
      else
      	l = line.split('	')
      	if l.length > 1
	        tick, type, text = l
	        uf = UserFeed.new
	        uf.tick = tick
	        uf.type_ = type.gsub(/\"/, "")
	        uf.text = text.gsub(/\"/, "")
	        if uf.save
	        else
	        	p 'issue'
	        	p line
	        end
	    end
      end
    end
  end
end
begin
	token = YAML::load(IO.read('config/stuff.yml'))['telegram_token']
	tickData = Update.order(id: :desc).first
	ufs = UserFeed.where(:type_ => 'Relation Change').where(:tick => tickData.id)
	if ufs
		Telegram::Bot::Client.run(token) do |bot|
			ufs.each do |u|
	            bot.api.send_message(chat_id: '-1001367880163', text: "[##{tickData.id} RELATION CHANGE] #{u.text}")
			end
		end
	end
rescue Exception => msg
	p msg.backtrace 
	puts msg
end


File.delete(file)