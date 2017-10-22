#!/usr/bin/env ruby
Dir.chdir "/home/ec2-user/tg_fang/"
load 'Rakefile'
require 'active_record'
require 'telegram/bot'
require './app/models/user'
require './app/models/alliance'
require './app/models/planet'
require './app/models/notification'
require './app/models/update'
require './app/models/intel'

configuration = YAML::load(IO.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(configuration)

token = YAML::load(IO.read('config/stuff.yml'))['telegram_token']

notifications = Notification.where(:sent => false).where(:type_ => ['Recall', 'NewFleet'])
begin
	Telegram::Bot::Client.run(token) do |bot|
  		notifications.each do |notification|
  			user = User.where(:id => notification.user_id).first
  			if user
  				if notification.type_ == 'Recall'
  					msg = "[RECALL] #{notification.x}:#{notification.y}:#{notification.z}"
  					planet = Planet.where(:x => notification.x).where(:y => notification.y).where(:z => notification.z).first
  					if planet
  						intel = Intel.where(:planet_id => planet.id).where('alliance_id IS NOT NULL').first
  						if intel
  							alliance = Alliance.where(:id => intel.alliance_id).first
  							msg += " [#{alliance.name}] "
  						end
  					end
  					msg += " has recalled from #{user.nick}"
				bot.api.send_message(chat_id: '-259425686', text: msg)
    				bot.api.send_message(chat_id: user.chat_id, text: msg)
    			end

  				if notification.type_ == 'NewFleet'
  					msg = "[INCOMING] #{notification.x}:#{notification.y}:#{notification.z}"
  					planet = Planet.where(:x => notification.x).where(:y => notification.y).where(:z => notification.z).first
  					if planet
  						intel = Intel.where(:planet_id => planet.id).where('alliance_id IS NOT NULL').first
  						if intel
  							alliance = Alliance.where(:id => intel.alliance_id).first
  							msg += " [#{alliance.name}] "
  						end
  					end
  					msg += " has launched at #{user.nick} LT: #{notification.lt} Fleet Count: #{notification.ship_count} Fleet Name: #{notification.fleet_name}"
    				bot.api.send_message(chat_id: user.chat_id, text: msg)
 				bot.api.send_message(chat_id: '-259425686', text: msg)
    			end
    		end
  		end
	end
	Notification.where(:sent => false).where(:type_ => ['Recall', 'NewFleet']).update_all(sent: true)
rescue Exception => msg
p msg.backtrace 
	puts msg
end

