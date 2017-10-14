require './models/user'
require './models/alliance'
require './models/planet'
require './models/attack_target'
require './models/ships'
require './models/update'
require './models/intel'
require './models/galaxy'
require './models/scan'
require './models/epeni'
require './models/dev_scan'
require './models/planet_scan'
require './models/unit_scan'
require './lib/message_sender'
require './models/sms_log'
require 'twilio-ruby'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(id: message.from.id, name: message.from.username)
  end

  def respond

    on /^\/?intel/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        if commands.length > 1
          cmd, planet, *more = commands
          if planet.split(/:|\+|\./).length == 3
            x, y, z = planet.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              if more.length == 0
                intel = Intel.where(:planet_id => planet.id).first
                if intel
                  res_message = ""
                  res_message += "\Nick: #{intel.nick}" unless intel.nick == ''
                  unless intel.alliance_id == nil
                      alliance = Alliance.where(:id => intel.alliance_id).first
                      if alliance
                          res_message = "\nAlliance: #{alliance.name}" 
                      else
                          res_message = "\nAlliance set with id ##{intel.alliance_id} but none found." 
                      end
                  end
                  res_message += "\nFake nick: #{intel.fakenick}" unless intel.fakenick == '' || intel.fakenick.nil?
                  res_message += "\nGov: #{intel.gov}" unless intel.gov == '' || intel.gov.nil?
                  res_message += "\nDefwhore: #{intel.defwhore}" unless intel.defwhore == '' || intel.defwhore.nil?
                  res_message += "\nAmps: #{intel.amps}" unless intel.amps == '' || intel.amps.nil?
                  res_message += "\nDists: #{intel.dists}" unless intel.dists == '' || intel.dists.nil?
                  res_message += "\nComment: #{intel.comment}" unless intel.comment == '' || intel.comment.nil?
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Intel on #{x}:#{y}:#{z} #{res_message}")
                else
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No intel for #{x}:#{y}:#{z}, go get some!")
                end
              else
                res_message = ""
                more.each do |option|
                  case option
                    when /\Aall/
                      command, value = option.split('=')
                      alliance = Alliance.where("name ilike '%#{value}%'").where(:active => true).first
                      if alliance
                        intel = Intel.where(:planet_id => planet.id).first_or_create
                        intel.alliance_id = alliance.id
                        if intel.save
                          res_message += "\nAlliance set as #{alliance.name}"
                        else
                          res_message = "\nError, contact admin"
                        end
                      else
                        res_message += "\n#{value} is not an alliance"
                      end
                    when /\Ani/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.name = value
                      if intel.save
                        res_message += "\nNick set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Atg/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.nick = value
                      if intel.save
                        res_message += "\nName set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Afa/
                        command, value = option.split('=')
                        intel = Intel.where(:planet_id => planet.id).first_or_create
                        intel.fakenick = value
                        if intel.save
                          res_message += "\nFake nick set as #{value}"
                        else
                          res_message = "\nError, contact admin"
                        end
                    when /\Abg/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.bg = value
                      if intel.save
                        res_message += "\nBg set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Ago/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.gov = value
                      if intel.save
                        res_message += "\nGov set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Arep/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.reportchan = value
                      if intel.save
                        res_message += "\nreport channel set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Adef/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.defwhore = value
                      if intel.save
                        res_message += "\nDefwhore set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Acov/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.covop = value
                      if intel.save
                        res_message += "\nCovop set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Arel/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.relay = value
                      if intel.save
                        res_message += "\nRelay set as #{value}"
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Aamp/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.amps = value
                      if intel.save
                        res_message += "\nAmps set as #{value} "
                      else
                        res_message = "\nError, contact admin "
                      end
                    when /\Adis/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.dists = value
                      if intel.save
                        res_message += "\nDists set as #{value} "
                      else
                        res_message = "\nError, contact admin"
                      end
                    when /\Acomm/
                      command, value = option.split('=')
                      intel = Intel.where(:planet_id => planet.id).first_or_create
                      intel.comment = value
                      if intel.save
                        res_message += "\nComment set as #{value} "
                      else
                        res_message = "\nError, contact admin "
                      end
                    else
                      bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: intel [x.z[.z]] [option=value]+")
                    end
                  end
                  if res_message.length > 0
                    bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{x}:#{y}:#{z} intel updated: #{res_message}")
                  end
                end
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet exists for #{x}:#{y}:#{z}")
              end
            elsif planet.split(/:|\+|\./).length == 2
              x, y = planet.split(/:|\+|\./)
              if more.length == 0
                planets = Planet.where(:x => x).where(:y => y).where(:active => true).order(z: :asc)
                res_message = ""
                if planets
                  planets.each do |planet|
                    intel = Intel.where(:planet_id => planet.id).first
                    res_message += "\nIntel for: #{x}:#{y}:#{planet.z}\n "
                    if intel
                      res_message += "\Nick: #{intel.nick}" unless intel.nick == ''
                      unless intel.alliance_id == nil
                        alliance = Alliance.where(:id => intel.alliance_id).where(:active => true).first
                        if alliance
                            res_message += "Alliance: #{alliance.name} | " 
                        else
                            res_message += "Alliance set with id ##{intel.alliance_id} but none found. | " 
                        end
                      end
                      res_message += "\nFake nick: #{intel.fakenick}" unless intel.fakenick == '' || intel.fakenick.nil?
                      res_message += "\nGov: #{intel.gov}" unless intel.gov == '' || intel.gov.nil?
                      res_message += "\nDefwhore: #{intel.defwhore}" unless intel.defwhore == '' || intel.defwhore.nil?
                      res_message += "\nAmps: #{intel.amps}" unless intel.amps == '' || intel.amps.nil?
                      res_message += "\nDists: #{intel.dists}" unless intel.dists == '' || intel.dists.nil?
                      res_message += "\nComment: #{intel.comment}" unless intel.comment == '' || intel.comment.nil?
                    else
                      res_message += "N/A" 
                    end
                  end
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Information for planets in: #{x}:#{y}\n #{res_message}")
                else
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No galaxy exists for #{x}:#{y}")
                end
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: intel [x.z[.z]] [option=value]+")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: intel [x.z[.z]] [option=value]+")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: intel [x.z[.z]] [option=value]+")
          end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You have insufficient access.")
      end
    end

    on /^\/?forcephone/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, user, phone = arguments
          if phone =~ /\A\+/
            phone[0] = ''
          end
          user = User.where('LOWER(name) = ? OR LOWER(nick) = ?', nick.downcase, nick.downcase).first
          if user
            user.phone = phone
            user.pubphone = true
            if user.save
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Phone updated.")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Not a user?")
          end
        else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: forcesms [user] [phone number[44XXXXXXXXX]]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?forceplanet/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        bot_config = YAML.load(IO.read('config/stuff.yml'))
        if commands.length == 3
          nick, planet, *mcore = arguments
          user = User.where('LOWER(name) = ? OR LOWER(nick) = ?', nick.downcase, nick.downcase).first
          if user
            x, y, z = planet.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              intel = Intel.where(:planet_id => planet.id).first_or_create
              alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
              if intel && user && alliance
                intel.nick = user.name
                intel.planet_id = planet.id
                user.planet_id = planet.id
                intel.alliance_id = alliance.id
                if intel.save && user.save
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{user.name} planet is set as #{x}:#{y}:#{z}.")
                else
                  bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
                end
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "There is no planet.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Not a user?")
          end
        else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: forceplanet [user] [x.y.z]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?exile/ do
      if check_access(message.from.id, 100)
        planets = Planet.where('x < 200').where(:active => true).group(:x,:y).select('x,y,count(z) as count_z').order('count_z asc')
        if planets
          gals = planets.length
          bracket = (gals * 0.2).floor
          brackets = {}
          brackets = Hash.new
          brackets.default = 0
          planets.each do |planet|
            brackets[planet.count_z] += 1
          end
          base_gal = 0
          base_planet = 0
          rest_gal = 0
          rest_planet = 0
          planet_left = 0
          brackets.each do |b, v|
            if (bracket - v) > 0
              base_gal = v
              base_planet = b
              bracket = bracket -v
            else
              rest_gal = v
              rest_planet = b
              planet_left = bracket
              break
            end
          end
          res_message = "Total random galaxies: #{gals}"
          res_message += "\n#{base_gal} galaxies with a maximum of #{base_planet} planets guaranteed to be in the exile bracket"
          res_message += "\nAlso in the bracket: #{planet_left} of #{rest_gal} galaxies with #{rest_planet} planets."
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planets?")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?edituser/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, nick, access = commands
          user = User.where(:name => nick).first
          if user
            user.name = nick
            user.active = true
            user.access = access
            if user.save
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User modified.")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error adding, contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "They're not a member!")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: edituser [tg_username] [access]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?dev/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'D').order(tick: :desc).first
            if scan
              dscan = Devscan.where(:scan_id => scan.id).first
              if dscan
                update = Update.order(id: :desc).first
                age = update.id - scan.tick
                res_message = "Development Scan on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age})"
                res_message += "\nTravel: #{travel_details(dscan.travel)} Infrastructure: #{infra_details(dscan.infrastructure)} Hulls: #{hulls_details(dscan.hulls)}"
                res_message += "\nWaves: #{waves_details(dscan.waves)}, Core: #{core_details(dscan.core)}, Covop: #{covop_details(dscan.covert_op)}, Mining: #{mining_cap(dscan.mining)}"
                total = dscan.wave_distorter+dscan.research_lab+dscan.military_centre+dscan.security_centre+dscan.structure_defence+dscan.finance_centre+dscan.light_factory+dscan.medium_factory+dscan.heavy_factory+dscan.wave_amplifier+dscan.eonium_refinery+dscan.crystal_refinery+dscan.metal_refinery
                res_message += "\nStructures: LFac: #{dscan.light_factory}, MFac: #{dscan.medium_factory}, HFac: #{dscan.heavy_factory}, Amp: #{dscan.wave_amplifier}"
                res_message += "\nDist: #{dscan.wave_distorter}, MRef: #{dscan.metal_refinery}, CRef: #{dscan.crystal_refinery}, ERef: #{dscan.eonium_refinery}"
                res_message += "\nResLab: #{dscan.research_lab} (#{dscan.research_lab.to_f/total*100}%), FC: #{dscan.finance_centre}, Mil: #{dscan.military_centre}"
                res_message += "\nSec: #{dscan.security_centre} (#{dscan.security_centre.to_f/total*100}%)"
                res_message += "\nSDef: #{dscan.structure_defence} (#{dscan.structure_defence.to_f/total*100}%)"
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Development Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No Development Scans of #{x}:#{y}:#{z} found")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command: unit [x.y.z].")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?createbcalc/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length >= 3
          cmd, class_, *coords = commands
          total_fleets = 0
          errors = 0
          error_messages = ""
          message = ""
          scans_missing = 0
          scans_missing_message = ""
          bcalc = "http://game.planetarion.com/bcalc.pl?"
          update = Update.order(id: :desc).first
          classes = {'FI' => 'Fighter', 'CO' => 'Corvette', 'DE' => 'Destroyer', 'FR' => 'Frigate', 'CR' => 'Cruiser', 'BS' => 'Battleship'}
          coords.each do |coord|
            x, y, z = coord.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              scan = Scan.where(:planet_id => planet.id).where(:scantype => 'A').order(tick: :desc).first
              scan = Scan.where(:planet_id => planet.id).where(:scantype => 'U').order(tick: :desc).first unless scan
              if scan
                uscans = Unitscan.where(:scan_id => scan.id).where("ships.class_ = '#{classes[class_]}'").joins(:ships).select('(ships.id - 1) as id, fang_unitscan.amount as total')
                total_fleets += 1
                age = update.id - scan.tick
                uscans.each do |uscan|
                  bcalc += "att_#{total_fleets}_#{uscan.id}=#{uscan.total}&"
                end
                bcalc += "att_planet_value_#{total_fleets}=#{planet.value}&"
                bcalc += "att_planet_score_#{total_fleets}=#{planet.score}&"
                bcalc += "att_coords_x_#{total_fleets}=#{planet.x}&"
                bcalc += "att_coords_y_#{total_fleets}=#{planet.y}&"
                bcalc += "att_coords_z_#{total_fleets}=#{planet.z}&"
                res_message += "#{planet.x}:#{planet.y}:#{planet.z} (S:#{scan.scantype} A:#{age}) | "
                  else
                    scans_missing += 1
                    scans_missing_message += "#{x}:#{y}:#{z} "
                  end
                else
                  errors += 1
                  error_messages += " #{x}:#{y}:#{z}" 
                end
              end
              bcalc += "att_fleets=#{total_fleets}"
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Following coords not found: #{error_messages}") unless errors == 0
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Following coords require scans: #{scans_missing_message}") unless scans_missing == 0
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Not created as no fleets with that class found") if total_fleets == 0
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Class: #{class_} Coords: #{res_message} Link: #{bcalc}") unless total_fleets == 0
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "createbcalc [CLASS] [x.y.z].")
          end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?bumchums/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        if commands.length < 3
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is bumchums [alliance] <alliance> [count].")
        else
          if commands.length == 4
            cmd, ally, ally2, number = commands
            alliance = Alliance.where("name ilike '%#{ally.downcase}%'").first
            alliance2 = Alliance.where("name ilike '%#{ally2.downcase}%'").first
            if alliance && alliance2
              planets = Planet.joins(:intel).select('x, y').where('heresy_intel.alliance_id = ? OR heresy_intel.alliance_id = ?', alliance.id, alliance2.id).having('count(*) >= ?', number.to_i).group(:x,:y)
              if planets
                coords = ""
                planets.each do |planet|
                  coords += "#{planet.x}:#{planet.y} "
                end
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Galaxies with at least #{number.to_i} bumchums from #{alliance.name} or #{alliance2.name}:\n #{coords}")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No galaxies with at least #{number.to_i} bumchums from #{alliance.name} or #{alliance2.name}")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{ally} or #{ally2} can't be found?")
            end
          else
            cmd, ally, number = commands
            alliance = Alliance.where("name ilike '%#{ally.downcase}%'").first
            if alliance
              planets = Planet.joins(:intel).select('x, y').where('heresy_intel.alliance_id = ?', alliance.id).having('count(*) >= ?', number.to_i).group(:x,:y)
              unless planets.empty?
                coords = ""
                planets.each do |planet|
                  coords += "#{planet.x}:#{planet.y} "
                end
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Galaxies with at least #{number.to_i} bumchums from #{alliance.name}:\n #{coords}")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No galaxies with at least #{number.to_i} bumchums from #{alliance.name}")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{ally} can't be found?")
            end
          end
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You have insufficient access.")
      end
    end

    on /^\/?bigdicks/ do
      if check_access(message.from.id, 100)
        users = User.joins(:epeni).select('name as name, rank as rank, penis as epenis').order("heresy_epenis.rank asc").limit(5)
        if users
          res_message = ""
          users.each do |user|
            res_message += "\n##{user.rank} #{user.name} #{number_nice(user.epenis)}"
          end
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Big Dicks: #{res_message}")
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "There is no penis")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?basher/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1] =~ /\A\d/
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              score = planet.score*paconfig['bash']['score']
              value = planet.value*paconfig['bash']['value']
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or above or score #{number_nice(score.round)} or above"
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet found for #{planet[1]}:#{planet[3]}:#{planet[5]}!")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command basher [x.y.z].")
          end
        else
          user = User.where(:id => message.from.id).first
          planet = Planet.where(:id => user.planet_id).first
          if planet
            score = planet.score*paconfig['bash']['score']
            value = planet.value*paconfig['bash']['value']
            res_message = "#{planet.x}:#{planet.y}:#{planet.z} can hit planets with value #{number_nice(value.round)} or above or score #{number_nice(score.round)} or above"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet set.")
          end
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?bashee/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1] =~ /\A\d/
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              score = planet.score/paconfig['bash']['score']
              value = planet.value/paconfig['bash']['value']
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or below or score #{number_nice(score.round)} or below"
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet found for #{planet[1]}:#{planet[3]}:#{planet[5]}!")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command bashee [x.y.z].")
          end
        else
          user = User.where(:id => message.from.id).first
          planet = Planet.where(:id => user.planet_id).first
          if planet
            score = planet.score/paconfig['bash']['score']
            value = planet.value/paconfig['bash']['value']
            res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or below or score #{number_nice(score.round)} or below"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet set.")
          end
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?amps/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        if commands.length == 2
          cmd, name, *more = commands
          if letter?(name)
            user = Intel.where(:nick => name).first
            if user
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{name} has #{user.amps} amps.")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No user found.")
            end
          elsif number?(name)
            users = Intel.where('amps >= ?', name).order(amps: :desc).limit(10)
            unless users.empty?
              res_message = "_______________________________\n"
              res_message = "|  #  | Nick          | Amps  |\n"
              res_message += "| --- |:-------------:| -----:|\n"
              count = 0
              users.each do |user|
                count += 1
                res_message += "|  #{count}   | #{user.nick} | #{user.amps}     |\n"
              end
              res_message += ""
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}", parse_mode: 'HTML')
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No scanners found with more than #{name} amps.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: amps [nick|amps]")
          end
        else 
          users = Intel.order(amps: :desc).limit(10)
          res_message = "_______________________________\n"
          res_message = "|  #  | Nick          | Amps  |\n"
          res_message += "| --- |:-------------:| -----:|\n"
          count = 0
          if users
            users.each do |user|
              count += 1
              res_message += "|  #{count}   | #{user.nick} | #{user.amps}     |\n"
            end
            res_message += ""

            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Top 10 amp scanners\n#{res_message}", parse_mode: 'HTML')
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No scanners?")
          end
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?lookup/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        if commands.length > 1
          cmd, planet, *more = commands
          if planet.split(/:|\+|\./).length == 3
            x, y, z = planet.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              res_message = "#{x}:#{y}:#{z} (#{planet.race}) '#{planet.rulername}' of '#{planet.planetname}'"
              specials = planet.special.split(',')
              s = ""
              specials.each do |special|
                case special
                  when 'P'
                    s += "Prot"
                  when 'D'
                    s += "Del"
                  when 'R'
                    s += "Reset"
                  when 'V'
                    s += "Vac"
                  when 'C'
                    s += "Closed"
                  when 'E'
                    s += "Exile"
                  when 'MoD'
                    s += "MoD"
                  when 'GC'
                    s += "GC"
                  when 'MoC'
                    s += "MoC"
                  when 'MoW'
                    s += "MoW"
                  else
                    s += ""
                end
              end
            unless s == ""
              res_message += " (#{s}) "
            end
            res_message += "\nScore: #{planet.score} (#{planet.score_rank}) Value #{planet.value} (#{planet.value_rank}) Size: #{planet.size} (#{planet.size_rank}) XP: #{planet.xp} (#{planet.xp_rank}) Idle: #{planet.idle}"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No planet exists for #{x}:#{y}:#{z}")
          end
        elsif planet.split(/:|\+|\./).length == 2
          x, y = planet.split(/:|\+|\./)
            galaxy = Galaxy.where(:x => x).where(:y => y).where(:active => true).first
          if galaxy
            planet_count = Planet.where(:x => x).where(:y => y).count
            res_message = "#{x}:#{y} '#{galaxy.name}' (#{planet_count})"
            res_message += "Score: #{galaxy.score} (#{galaxy.score_rank}) Value: #{galaxy.value} (#{galaxy.value_rank}) Size: #{galaxy.size} (#{galaxy.size_rank}) XP: #{galaxy.xp} (#{galaxy.xp_rank})"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No galaxy exists for #{x}:#{y}")
          end
        elsif planet =~ /\A./
          alliance = Alliance.where("name ilike '%#{planet}%'").where(:active => true).first
          if alliance
            res_message = "'#{alliance.name}' Members: #{alliance.members} (#{alliance.members_rank})"
            res_message += "Score: #{alliance.score} (#{alliance.score_rank}) Points: #{alliance.points} (#{alliance.points_rank}) Size: #{alliance.size} (#{alliance.size_rank}) Avg: #{alliance.size_avg} (#{alliance.size_avg_rank})"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            intel = Intel.where("nick ilike '%#{planet}%'").first
            if intel
              planet = Planet.where(:id => intel.planet_id).first
              if planet
                res_message = "#{planet.x}:#{planet.y}:#{planet.z} (#{planet.race}) '#{planet.rulername}' or '#{planet.planetname}'"
                res_message += "\nScore: #{planet.score} (#{planet.score_rank}) Value #{planet.value} (#{planet.value_rank}) Size: #{planet.size} (#{planet.size_rank}) XP: #{planet.xp} (#{planet.xp_rank}) Idle: #{planet.idle}"
              else
                res_message = "#{planet} doesn't have a planet?"
              end
            else
              res_message = "#{planet} not found."
            end
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          end
        else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is lookup [x.y.z|x.y|ally_name]")
        end
      else
        user = User.where(:id => message.from.id).first
        if user
          planet = Planet.where(:id => user.planet_id).where(:active => true).first
          if planet
            res_message = "#{planet.x}:#{planet.y}:#{planet.z} (#{planet.race}) '#{planet.rulername}' of '#{planet.planetname}'"
            specials = planet.special.split(',')
            s = ""
            specials.each do |special|
              case special
                when 'P'
                  s += "Prot"
                when 'D'
                  s += "Del"
                when 'R'
                  s += "Reset"
                when 'V'
                  s += "Vac"
                when 'C'
                  s += "Closed"
                when 'E'
                  s += "Exile"
                when 'MoD'
                  s += "MoD"
                when 'GC'
                  s += "GC"
                when 'MoC'
                  s += "MoC"
                when 'MoW'
                  s += "MoW"
                else
                  s += ""
              end
            end
            unless s == ""
              res_message += " (#{s}) "
            end
            res_message += "\nScore: #{planet.score} (#{planet.score_rank}) Value #{planet.value} (#{planet.value_rank}) Size: #{planet.size} (#{planet.size_rank}) XP: #{planet.xp} (#{planet.xp_rank}) Idle: #{planet.idle}"
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You haven't set a planet?")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No user?")
        end
      end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No access.")
      end
    end

    on /^\/?planet/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'P').order(tick: :desc).first
            if scan
              pscan = Planetscan.where(:id => scan.id).first
              if pscan
                update = Update.order(id: :desc).first
                age = update.id - scan.tick
                res_message = "Planet Scan on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age})"
                res_message += "\nRoids: m: #{number_nice(pscan.roid_metal)} c: #{number_nice(pscan.roid_crystal)} e: #{number_nice(pscan.roid_eonium)}"
                res_message += "\nResources: m:#{number_nice(pscan.res_metal)} c:#{number_nice(pscan.res_crystal)} e:#{number_nice(pscan.roid_eonium)}"
                res_message += "\nProd: #{number_nice(pscan.prod_res)} Selling: #{number_nice(pscan.sold_res)} Agents: #{number_nice(pscan.agents)} Guards: #{number_nice(pscan.guards)}"
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Planet Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No Planet Scans of #{x}:#{y}:#{z} found")
            end
              
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "planet [x.y.z].")
        end
      else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end
    
    on /^\/?tick/ do
      if check_access(message.from.id, 100)
        update = Update.order(id: :desc).first
        commands = @message.text.split(' ')
        if commands.length == 2
          cmd, tick = commands
          if number?(tick)
            if update.id == tick.to_i
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{update.id} is current tick.")
            else
              tick_next = tick.to_i - update.id
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{tick} is in #{tick_next} ticks.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: tick <tick>")
          end
        else 
          if update
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{update.id} is current tick.")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Ticks haven't started yet.")
          end
        end
      else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?help/ do
      msg = "
` Help, for further details specify help [command]`
` All commands can be done in channel or in DM`
` --------------------------------------------`
` adduser amps au aually bashee basher        `
` bigdicks bumchums call cost createbcalc dev `
` edituser eff forceplanet forcephone intel   `
` jgp jgpally links lookup loosecunts maxcap  `
` myamps myplanet myphone news planet racism  `
` remuser req roidcost seagal search ship sms `
` smslog spam spamin stop top10 tick unit     `
` value whois xp                              ` 
` --------------------------------------------`"
      bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{msg}", parse_mode: 'Markdown')
    end

    on /^\/?call/ do
      commands = @message.text.split(' ')
      if commands.length == 2
        user = User.where("LOWER(name) ilike '%#{commands[1].downcase}%' OR LOWER(nick) ilike '%#{commands[1].downcase}%%'")
        if user.count == 1
          user = user.first
          if user.phone != ''
            sender = User.where(:id => message.from.id).first
            bot_config = YAML.load(IO.read('config/stuff.yml'))
            account_sid = bot_config['twilio']['account_sid']
            auth_token = bot_config['twilio']['auth_token']
            @client = Twilio::REST::Client.new account_sid, auth_token
            @client.calls.create(
              from: bot_config['twilio']['number'],
              to: '+'+user.phone.to_s,
                url: 'https://demo.twilio.com/welcome/voice/'
            )
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Calling #{user.name}.")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{commands[1]} never set their phone number!!!.")
          end
        elsif user.count > 1
          users = user.map(&:name)
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Who are you trying to text: #{users.join(', ')}.")
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No user found.")
        end
      end
    end

    on /^\/?stop/ do
      commands = @message.text.split(' ')
      if efficiency_args?(commands.drop(1).join(' '))
        cmd, number, ship, target = commands
        target = target || 't1'
        target = target.downcase
        ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first
        if ship
          number = number_short(number)
          paconfig = YAML.load(IO.read('config/pa.yml'))
          efficiency = paconfig['teffs'][target]
          ship_value = paconfig['ship_value'].to_i
          defences = Ships.where("#{target}" => ship.class_)
          unless defences.empty?
            if ship.class_ == "Roids"
              res_message = "Capturing"
            elsif ship.class_ == "Struct"
              res_message = "Destroying"
            else
              res_message = "Stopping"
            end
            res_message += " #{number_nice(number)} #{ship.name} (#{number_nice(((number.to_i*ship.total_cost)/ship_value).floor)}) as #{target} requires "
            defences.each do |defence|
              if defence.type_.downcase == 'emp'
                  required = ((number.to_i/((100-ship.empres).to_f/100)/defence.guns).to_f).ceil/efficiency
              else
                  required = ((((ship.armor*number.to_i)/defence.damage).to_f).ceil/efficiency)
              end
              res_message += "#{defence.name}: #{number_nice(required.floor)} (#{number_nice(((defence.total_cost*required)/ship_value).floor)}) "
            end
          else
            res_message = "#{ship.name} will not be hit by anything (#{target})"
          end
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}.")
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No ship named #{ship}.")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: stop [number] [ship] [t1|t2|t3].")
      end
    end

    on /^\/?sms/ do
      if check_access(message.from.id, 100)
        commands = @message.text.split(' ')
        if commands.length >= 3
          cmd, user, *message_ = commands
          user = User.where("LOWER(name) ilike '%#{user.downcase}%' OR LOWER(nick) ilike '%#{user.downcase}%'")
          if user.count == 1
            user = user.first
            if user.phone != '' && user.phone != nil
              sender = User.where(:id => message.from.id).first
              bot_config = YAML.load(IO.read('config/stuff.yml'))
              account_sid = bot_config['twilio']['account_sid']
              auth_token = bot_config['twilio']['auth_token']
              @client = Twilio::REST::Client.new account_sid, auth_token
              @client.messages.create(
                from: bot_config['twilio']['sms_number'],
                to: '+'+user.phone,
                body:  user.name + ': ' + message_.join(' ')
              )
              log = add_log(sender.id, user.id,'+'+user.phone, message_.join(' '))
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Message sent [##{log}]")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{user.name} never set their phone number!!!")
            end
          elsif user.count > 1
              users = user.map(&:name)
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Who are you trying to text: #{users.join(', ')}.")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No user found.")
          end
        else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: sms [user] [message]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: " Not enough access.")
      end
    end

    on /^\/?adduser/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, nick, access = commands
          unless User.exists?(name: nick, active: true)
            u = User.where(name: nick).first
            if u
	    	      msg = add_user(u, access, nick, message.from.id)
            	bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: msg)
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User not found?")
 	          end
	         else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "They're already a member!")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: adduser [telegram_username] [access]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?setnick/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, nick, name = commands
          u = User.where("LOWER(name) = '#{nick.downcase}'").first
          if u
            u.nick = name
            if u.save
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User updated")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Contact admin")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User not found?")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: setnick [telegram_username] [irc_nick]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?setphone/ do
      if check_access(message.from.id, 1000)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, nick, phone = commands
          u = User.where("LOWER(name) = '#{nick.downcase}'").first
          if u
            u.phone = phone
            u.pubphone = true
            if u.save
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User updated")
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Contact admin")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "User not found?")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: setphone [telegram_username] [phone number]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "You don't have enough access.")
      end
    end

    on /^\/?mynick/ do
      commands = @message.text.split(' ')
      if commands.length == 2
        cmd, nick = commands
        user = User.where(:id => message.from.id).first
        if user
          user.nick = nick
          if user.save
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Nick updated.")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Not a user?")
          end
      else 
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: mynick [Nick]")
      end
    end

    on /^\/?myphone/ do
      commands = @message.text.split(' ')
      if commands.length == 2
        cmd, phone = commands
        user = User.where(:id => message.from.id).first
        if user
          user.phone = phone
          user.pubphone = true
          if user.save
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Phone updated.")
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Not a user?")
          end
      else 
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: myphone [phone number[44XXXXXXXXX]]")
      end
    end

    on /^\/?myplanet/ do
      commands = @message.text.split(' ')
      bot_config = YAML.load(IO.read('config/stuff.yml'))
      if commands.length == 2
        cmd, planet = commands
        if planet.split(/:|\+|\./).length == 3
          x, y, z = planet.split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            user = User.where(:id => message.from.id).where(:active => true).first
            intel = Intel.where(:planet_id => planet.id).first_or_create
            alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
            if intel && user && alliance
              intel.nick = user.nick
              intel.planet_id = planet.id
              user.planet_id = planet.id
              intel.alliance_id = alliance.id
              if intel.save && user.save
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Your planet is set as #{x}:#{y}:#{z}.")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
              end
            else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "There is no planet.")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: myplanet [x.y.z]")
        end
      elsif commands.length == 3
        cmd, x, y, z = commands
        if number?(x) && number?(y) && number?(z)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            user = User.where(:id => message.from.id).where(:active => true).first
            intel = Intel.where(:planet_id => planet.id).first_or_create
            alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
            if intel && user && alliance
              intel.nick = user.name
              intel.planet_id = planet.id
              user.planet_id = planet.id
              intel.alliance_id = alliance.id
              if intel.save && user.save
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Your planet is set at #{x}:#{y}:#{z}.")
              else
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Error, contact admin.")
            end
          else
            bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "There is no planet.")
          end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "There is no planet.")
        end
      else 
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: myplanet [x.y.z]")
      end
    end

    on /^\/?ship/ do
      commands = @message.text.split(' ')
      if commands.length == 2
        cmd, ship = commands
        ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first
        if ship
            res_message = "#{ship.name} (#{ship.race}) is class #{ship.class_} | Target 1: #{ship.t1} |"
            res_message += " Target 2: #{ship.t2} |" if ship.t2 != ''
            res_message += " Target 3: #{ship.t3} |" if ship.t3 != ''
            res_message += " Type: #{ship.type_} | Init: #{ship.init} | EMPres: #{ship.empres} |"
            if ship.type_.downcase == 'emp'
                res_message += " Guns: #{ship.guns} |"
            else
                res_message += " D/C: #{number_nice(((ship.damage*10000)/ship.total_cost).floor)} |"
            end
            res_message += " A/C: #{number_nice((ship.armor*10000)/ship.total_cost)}"
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: res_message)
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No ship named #{ship.name}]")
        end
      else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: ship [ship]")
      end
    end

    on /^\/?cost/ do
      commands = @message.text.split(' ')
      if commands.length == 3
          cmd, count, ship = commands
          ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first
          if ship
              count = number_short(count)
              metal = ship.metal.to_i * count.to_i
              crystal = ship.crystal.to_i * count.to_i
              eonium = ship.eonium.to_i * count.to_i
              paconfig = YAML.load(IO.read('config/pa.yml'))
              ship_value = paconfig['ship_value'].to_i
              res_value = paconfig['res_value'].to_i
              cost = (ship.total_cost.to_i * count.to_i)/ship_value
              res_message = "Buying #{number_nice(count)} #{ship.name} (#{number_nice((cost.floor))}) will cost #{number_nice(metal)} metal, #{number_nice((crystal.floor))} crystal and #{number_nice((eonium.floor))} eonium"
              paconfig['govs'].each do |gov|
                  bonus = paconfig[gov.first]['prodcost']
                  if bonus != 0
                      metal = ((ship.metal.to_i * (1 + bonus)).floor * count.to_i)
                      crystal = ((ship.crystal.to_i * (1 + bonus)).floor * count.to_i)
                      eonium = ((ship.eonium.to_i * (1 + bonus)).floor * count.to_i)
                      res_message += " #{paconfig[gov.first]['name']}: #{number_nice((metal.floor))} metal, #{number_nice((crystal.floor))} crystal and #{number_nice((eonium.floor))} eonium"
                  end
              end
              value = (ship.total_cost.to_i * count.to_i) * (1.0/ship_value - 1.0/res_value)
              res_message += " It will add #{value.floor} value."
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
          else
              bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No ship named #{ship}")
          end
      else 
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command is: cost [number] [ship]")
      end
    end

    on /^\/?eff/ do
      commands = @message.text.split(' ')
      if commands.length >= 3
        command, number, ship, target = commands
        target = target || 't1'
        puts target
        target = target.downcase
        ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first
        if ship
            number = number_short(number)
            paconfig = YAML.load(IO.read('config/pa.yml'))
            efficiency = paconfig['teffs'][target]
            ship_value = paconfig['ship_value'].to_i
            ship_total_value = ((number.to_i*ship.total_cost.to_i)/ship_value).round
            if ship.damage
                total_damage = ship.damage * number.to_i
            end
            if ship.t1 == 'Struct'
                destroyed = total_damage/500
                cons_value = paconfig['cons_value'].to_i
                destroy_spec = destroyed * cons_value
                res_message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) will destroy #{number_nice(destroyed.floor)} (#{number_nice(destroy_spec.floor)}) structures."
            elsif ship.t1 == 'Roids'
                captured = total_damage/50
                roid_value = paconfig['roid_value'].to_i
                roid_value_lost = (captured * roid_value).round
                res_message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) will capture #{number_nice(captured.floor)} (#{number_nice(roid_value_lost.floor)}) asteroids"
                bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
            else
                target_class = ship["#{target}"]
                targets = Ships.where(:class_ => target_class)
                unless targets.empty?
                    if ship.type_.downcase == "normal" || ship.type_.downcase == "cloak"
                        attack = "destroy "
                    elsif  ship.type_.downcase == "emp"
                        attack = "hug "
                    elsif ship.type_.downcase == "steal"
                        attack = "steal "
                    else
                        attack = "Error, see admin"
                    end
                    res_message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) targetting #{target_class} will #{attack}"
                    targets.each do |target|
                        if ship.type_.downcase == "emp"
                            destroyed = ((efficiency * (ship.guns.to_i*number.to_i)*(100-target.empres.to_i))/100).round
                        else
                            destroyed = ((efficiency * total_damage)/target.armor.to_i)
                        end
                        value_lost = ((target.total_cost.to_i*destroyed)/ship_value)
                        res_message += "#{target.name}: #{number_nice(destroyed.floor)} (#{number_nice(value_lost.floor)}) "
                    end
                    bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{res_message}")
                else
                    bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "#{ship} has no targets for class #{target_class}")
                end
            end
        else
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "No ship named #{ship}")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "Command: /eff [number] [ship] [t1|t2|t3]")
      end
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def num(num)
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def rnd(num)
    '%.2f' % num
  end

  def add_user(user, access, nick, name)
    user.active = true
    user.access = access
    user.nick = nick
    if user.save
      response = "User added."
    else
      response = "Error adding, contact admin."
    end
    return response
  end

  def ndate(date)
    unless date.nil?
      DateTime.strptime(date, '%Y-%m-%d %H:%M:%S%z').strftime("%d-%m-%Y")
    end
  end

  def number_short(num)
    case num[-1].downcase
      when "k"
        num.gsub('k','000')
      when "m"
        num.gsub('m','000000')
      when "b"
        num.gsub('b','000000000')
      else
        num
    end
  end

  def number_nice(num)
    num.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def efficiency_args?(check)
    check =~ /(\d+(?:\.\d+)?[kmb]?)\s+(\w+)(?:\s+(t1|t2|t3))?/
  end

  def letter?(check)
    check =~ /\A[A-Za-z]+\Z/
  end

  def number?(check)
    check =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
  end

  def bravery(planet, target)
    return [0.2,[2.2,target.score/planet.score].min-0.2].max * [0.2,[1.8,target.value/planet.value].min-0.1].max/((6+[4,planet.score/planet.value].max)/10)
  end

  def cap_rate(planet, target = nil)
    paconfig = YAML.load(IO.read('config/pa.yml'))
    mincap = paconfig['roids']['mincap']
    maxcap = paconfig['roids']['maxcap']
    if target == nil
      return maxcap
    end
    mod = (planet.value/target.value)*0.5
    return [mincap,[maxcap*modifier, maxcap].min].max
  end

  def calc_xp(planet, target, cap = nil)
    cap = max_cap(planet, target) if cap == nil
    return cap * (bravery(planet, target) * 10)
  end

  def max_cap(planet, attacker = nil)
    return (planet.size * cap_rate(planet, attacker))
  end

  def check_access(user, access)
    user = User.where(:id => user).first
    if user
    	if user.access >= access
      		return true
    	else
      		return false
    	end
    else
	return false
    end
  end

  def addGalaxy(attack_id, x, y)
    planets = Planet.where(:x => x).where(:y => y).where(:active => true)
    if planets
      planets.each do |planet|
        target = AttackTarget.new(planet_id: planet.id, attack_id: attack_id)
        if target.save
        else
          return "Error adding #{x}:#{y} "
        end
      end
      return ""
    else
      return "#{x}:#{y} doesn't exist "
    end
  end

  def removeGalaxy(attack_id, x, y)
    planets = Planet.where(:x => x).where(:y => y).where(:active => true)
    if planets
      planets.each do |planet|
        target = AttackTarget.where(planet_id: planet.id, attack_id: attack_id).destroy_all
        if target
        else
          return "Error removing #{x}:#{y} "
        end
      end
      return ""
    else
      return "#{x}:#{y} doesn't exist "
    end
  end

  def addPlanet(attack_id, x, y, z)
    planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
    if planet
      target = AttackTarget.new(planet_id: planet.id, attack_id: attack_id)
      if target.save
        return ""
      else
        return "Error adding #{x}:#{y}:#{z} "
      end
    else
      return "#{x}:#{y}:#{z} doesn't exist "
    end
  end

  def removePlanet(attack_id, x, y, z)
    planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
    if planet
      target = AttackTarget.where(planet_id: planet.id, attack_id: attack_id).destroy_all
      if target
        return ""
      else
        return "Error removing #{x}:#{y}:#{z} "
      end
    else
      return "#{x}:#{y}:#{z} doesn't exist "
    end
  end

  def self.letter?(check)
    check =~ /\A[^A-Za-z$]+\Z/
  end

  def self.number?(check)
    check =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/
  end

  def generateScanUrl(type,x,y,z,pa_scan_type)
    paconfig = YAML.load(IO.read('config/pa.yml'))
    if type == 'single'
      url = paconfig['reqscan'].gsub('TTT', "#{pa_scan_type}").gsub('XXX', "#{x}").gsub('YYY', "#{y}").gsub('ZZZ', "#{z}")
    end
    return url
  end

  def reply_markup(md)
    ReplyMarkupFormatter.new(md).get_markup
  end

  def add_log(sender,receiver,phone,sms_text)
    log = SmsLog.new
    log.sender_id = sender
    log.receiver_id = receiver
    log.phone = phone
    log.sms_text = sms_text
    if log.save
      return log.id
    else
      return false
    end
  end

  def mining_cap(level)
    case level
      when 0
        return "100 roids (scanner!)"
      when 1
        return "200 roids"
      when 2
        return "300 roids"
      when 3
        return "500 roids"
      when 4
        return "750 roids"
      when 5
        return "1k roids"
      when 6
        return "1250 roids"
      when 7
        return "1500 roids"
      when 8
        return "2000 roids"
      when 9
        return "2500 roids"
      when 10
        return "3000 roids"
      when 11
        return "3500 roids"
      when 12
        return "4500 roids"
      when 13
        return "5500 roids"
      when 14
        return "6500 roids"
      when 15
        return "8000 roids"
      when 16
        return "top10 or dumb"
      else
        return "eh?"
    end
  end

  def travel_details(travel)
      return "eta -#{travel}"
  end

  def infra_details(level)
    case level
      when 0
        return "20 constructions"
      when 1
        return "50 constructions"
      when 2
        return "100 constructions"
      when 3
        return "150 constructions"
      when 4
        return "200 constructions"
      when 5
        return "300 constructions"
      else
        return ""
    end
  end

  def hulls_details(level)
    case level
      when 1
        return "FI/CO"
      when 2
        return "FR/DE"
      when 3
        return "CR/BS"
      else
        return ""
    end
  end

  def waves_details(level)
    case level
      when 0
        return "Planet"
      when 1
        return "Landing"
      when 0
        return "Development"
      when 3
        return "Unit"
      when 4
        return "News"
      when 5
        return "Incoming"
      when 6
        return "JGP"
      when 7
        return "Advanced Unit"
      else
        return ""
    end
  end

  def core_details(level)
    case level
      when 1
        return "1000 ept"
      when 2
        return "4000 ept"
      when 3
        return "8000 ept"
      when 4
        return "15000 ept"
      when 5
        return "25000 ept"
      else
        return ""
    end
  end

  def covop_details(level)
    case level
        when 0
      return "Research hack"
        when 1
      return "Lower stealth"
        when 2
      return "Blow up roids"
        when 3
      return "Blow up ships"
        when 4
      return "Blow up guards"
        when 5
      return "Blow up amps/dists"
        when 6
      return "Resource hacking (OMG!)"
        when 7
      return "Blow up strucs"
        else
      return ""
    end
  end



  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
