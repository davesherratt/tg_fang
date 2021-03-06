require './app/models/user'
require './app/models/alliance'
require './app/models/planet'
require './app/models/attack_target'
require './app/models/ships'
require './app/models/update'
require './app/models/intel'
require './app/models/galaxy'
require './app/models/scan'
require './app/models/epeni'
require './app/models/dev_scan'
require './app/models/planet_scan'
require './app/models/planet_history'
require './app/models/incoming'
require './app/models/incs_data'
require './app/models/incs_peep'
require './app/models/fleet_scan'
require './app/models/unit_scan'
require './lib/message_sender'
require './app/models/sms_log'
require 'twilio-ruby'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.where(user_telegram_chat_id: @message.from.id).first
  end


  def chat_user(message, cmd)
    user = User.where(user_telegram_chat_id: @message.from.id).first
    if (user)
      if (user.user_telegram_chat_id != nil && cmd[0] == ".")
        return user.user_telegram_chat_id
      else
        return message
      end
    elsif cmd[1..-1] == 'register'
      return message
    end
  end

  def respond

    on /^(.)mypass/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
        if commands.length == 2
          cmd, pass = commands
          user = User.where(:chat_id => message.from.id).first
          if user
            config = YAML.load(IO.read('config/stuff.yml'))
            user.passwd = pass
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Password set, can access website at #{config[:url]}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: mypass [password]")
        end
      end
    end

    on /^(\/|!|\+|.)launch/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
        if commands.length == 3
          cmd, class_, land_tick = commands
          class_eta = { 'fi' => 8, 'co' => 8, 'fr' => 9, 'de' => 9, 'cr' => 10, 'bs' => 10 }
          unless number?(class_)
            class_ = class_eta[class_].to_i
          end
          tickData = Update.order(id: :desc).first
          launch_tick = land_tick.to_i - class_.to_i
          prelaunch_tick = land_tick.to_i - class_.to_i + 1
          prelaunch_mod = launch_tick.to_i - tickData.id
          res_message = "eta #{class_} landing pt #{land_tick} (currently #{tickData.id}) must launch at pt #{launch_tick}, or with prelaunch tick #{prelaunch_tick} (currently +#{prelaunch_mod})" 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: res_message)
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is <eta|class> <LT>")
        end
      end
    end

    on /^(\/|!|\+|.)incs/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          cmd, date = commands
          incs = IncsData.where(:date => date).select('ally, incs').order('incs desc')
          if incs
            msg = ""
            incs.each do |inc|
              msg << "#{inc.ally} #{inc.incs}\n"
            end
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Heresy Incomings on #{date}\n#{msg}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No data.")
          end
        else
          incs = IncsData.group('ally').select('ally, count(*) as incs_count').order('incs_count desc')
          if incs
            msg = ""
            incs.each do |inc|
              msg << "#{inc.ally} #{inc.incs_count}\n"
            end
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Heresy Incomings\n#{msg}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No incs?")
          end
        end
      end
    end

    on /^(\/|!|\+|.)haters/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          cmd, date = commands
          incs = IncsPeep.where(:date => date).select('attacker_x, attacker_y, attacker_z, ally, incs').order('incs desc').limit(10)
          if incs
            msg = ""
            incs.each do |inc|
              msg << "#{inc.attacker_x}:#{inc.attacker_y}:#{inc.attacker_z} #{inc.ally} #{inc.incs}\n"
            end
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Heresy Top Haters on #{date}\n#{msg}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No data.")
          end
        else
          incs = IncsPeep.group('attacker_x, attacker_y, attacker_z, ally').select('attacker_x, attacker_y, attacker_z, ally, sum(incs) as incs_count').order('incs_count desc').limit(1)
          if incs
            msg = ""
            incs.each do |inc|
              msg << "#{inc.attacker_x}:#{inc.attacker_y}:#{inc.attacker_z} #{inc.ally} #{inc.incs_count}\n"
            end
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Heresy Top Haters\n#{msg}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No incs?")
          end
        end
      end
    end

    on /^(\/|!|\+|.)attack/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          cmd, *more = commands

          config = YAML.load(IO.read('config/stuff.yml'))
          case more[0]
            when 'list'
              tickData = Update.order(id: :desc).first
              if tickData
                tick = tickData.id
              else
                tick = 0
              end
              attacks = Attack
              unless check_access(message.from.id, 500)
                landcheck = tick + config['attactive']
                attacks.where('landtick <= ?', landcheck)
              end
              attacks.where('landtick >= ?', tick+3).order(id: :asc)
              unless attacks
                res_message = "Open attacks: "
                attacks.each do |attack|
                  res_message += "(#{attack.id} LT: #{attack.landtick} #{attack.comment}) "
                end
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: res_message)
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There are no active attacks")
              end
            when /[0-9]+/
              tickData = Update.order(id: :desc).first
              if tickData
                tick = tickData.id
              else
                tick = 0
              end
              attack = Attack.where(:id => more[0]).first
              if attack
                unless check_access(data.user, 500) && attack.landtick > (tick + fangconfig['attactive'])
                  send_message data.channel, "<@#{data.user}> Attack ##{arguments.first} is not open yet"
                else
                  res_message = "##{attack.id} LT: #{attack.landtick} RT: {attack.comment} | #{fangconfig['url']}/attack/#{attack.id} | "
                  planets = Planet.joins(:fang_attack).where(:fang_attack_target => {:attack_id => attack.id}).select(:x, :y, :z)
                  planetData = []
                  unless planets.empty?
                    planets.each do |planet|
                      planetData << "#{planet.x}:#{planet.y}:#{planet.z} "
                    end
                  end
                  res_message += planetData.join(' ')
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: res_message)
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No attack exists with an id ##{more[0]}")
              end
            when 'new'
              if check_access(message.from.id, 200)
                  tickData = Update.order(id: :desc).first
                  if tickData
                    tick = tickData.id
                  else
                    tick = 0
                  end
                  points = more.join(' ').split(/(?:new\s+)?(\d+)\s+(?:(\d+)\s*w(?:ave)?s?\s+)?([. :\-\d,]+)\s(r\d+)?/)
                  landtick = points[1].to_i
                  if landtick < config['protection'].to_i
                    landtick += tick
                  elsif landtick <= tick
                    bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You cannot create attacks in the past")
                    return
                  end
                  attack = Attack.new
                  attack.landtick = landtick
                  attack.release_tick = points[4].gsub('r', '')
                  attack.waves = points[2].to_i
                  if attack.save
                    coords = points[3].split(' ')
                    messages = ""
                    coords.each do |coord|
                      c = coord.split(/(\d+)([. :\-])(\d+)(\2(\d+))?/)
                      if c.length < 5
                        messages += addGalaxy(attack.id, c[1], c[3])
                      else
                        messages += addPlanet(attack.id, c[1], c[3], c[5])
                      end
                    end
                    scans = config['attack']['attscans']
                    if scans.length > 0
                      scans.split('').each do |scan|
                        targets = AttackTarget.where(:attack_id => attack.id)
                        targets.each do |target|
                          scan_available = Scan.where(:planet_id => target.planet_id).where(:tick => tick).where(:scantype => scan).first
                          unless scan_available
                            user = User.where(:slack_id => data.user).first
                            request = Request.new(:planet_id => target.planet_id, :dists => 0, :scantype => scan, :requester_id => user.user_id, :active => true, :tick => tick)
                            if request.save
                              #ignore
                            else
                              messages += " | Issue requesting scans!"
                            end
                          end
                        end
                      end
                      #Requested %d scans. !request cancel %s:%s to cancel the request.
                      #send_message config['scan_channel'], "Requested #{scans} from #{coords.join(' ')} for attack. .request links for details"
                      messages += " #{scans} scans requested."
                    end
                    bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "##{attack.id} LT: #{attack.landtick} RT: #{attack.release_tick} | #{config['url']}/attack/#{attack.id} | #{messages}")
                  else
                    bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
                  end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not enough access.")
              end
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: List open attacks or create one
        \nattack [list|<id>|new]
        \nattack new [landtick] [waves] coords [releasetick]
        \nattack new 666 3w 1:1:1 1:2 3:4 r400")            
        end
      end
    end

    on /^(\/|!|\+|.)not_channel/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
  	    bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: message.chat.id.to_s + ' channel added')
      end
    end

    on /^(\/|!|\+|.)register/ do
      commands = @message.text.split(' ')
      if message.chat.id > 0
        if commands.length == 2
          cmd, api_key = commands
          user = User.where(:user_api_key => api_key).first
          if user
            user.nick = user.username
            user.name = user.username
            user.access = 100
            user.chat_id = message.chat.id
            user.user_telegram_chat_id = message.chat.id
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You're registered, to get TG notifications set your PA Notification email as : #{user.username}@patools.ninja")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
            end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: register [Nick]")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Only in a direct message!")
      end
    end


=begin
    on /^(\/|!|\+|.)register/ do
      commands = @message.text.split(' ')
      if commands.length == 2
        cmd, nick = commands
        user = User.where(:id => message.from.id).first
        if user
          user.nick = nick
          user.name = nick
          user.chat_id = message.chat.id
          if user.save
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You're registered, to get TG notifications set your PA Notification email as : #{nick}@patools.ninja")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
          end
      else 
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: register [Nick]")
      end
    end
=end
    on /^(\/|!|\+|.)afford/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 3
          cmd, coords, ship = commands
          if coords.split(/:|\+|\./).length == 3
            paconfig = YAML.load(IO.read('config/pa.yml'))
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              ship = Ships.where("lower(name) = '#{ship.downcase}'").first
              ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first if !ship
              if ship
                scan = Scan.where(:planet_id => planet.id).where(:scantype => 'P').order(tick: :desc).first
                if scan
                  pscan = PlanetScan.where(:scan_id => scan.id).first

                  tick_now = Update.order(id: :desc).first
                  tick = scan.tick
                  scan_age = tick_now.id - tick
                  res_metal = pscan.res_metal
                  res_crystal = pscan.res_crystal
                  res_eonium = pscan.res_eonium
                  prod_res = pscan.prod_res
                  rand_id = scan.pa_id
                  cost_metal = ship.metal
                  cost_crystal = ship.crystal
                  cost_eonium = ship.eonium
                  total_cost = ship.total_cost

                  class_factory_table = {'Fighter' => 'factory_usage_light', 'Corvette' => 'factory_usage_light', 'Frigate' => 'factory_usage_medium',
                               'Destroyer' => 'factory_usage_medium', 'Cruiser' => 'factory_usage_heavy', 'Battleship' => 'factory_usage_heavy'}
                  prod_modifier_table = {'None' => 0.0, 'Low' => 0.33, 'Medium' => 0.66, 'High' => 1.0}
        
                  capped_number = [(res_metal/cost_metal), (res_crystal/cost_crystal), (res_eonium/cost_eonium)].min
                  overflow = res_metal+res_crystal+res_eonium-(capped_number*(cost_metal+cost_crystal+cost_eonium))
                  buildable = capped_number + ((overflow*0.95)/total_cost)
                  res_message = "Latest Planet Scan on #{x}:#{y}:#{z} (id: #{rand_id}, pt: #{tick}, age: #{scan_age})"
                  res_message += "\nCan purchase #{number_nice(buildable.round)} #{ship.name}'s"
                  paconfig['govs'].each do |gov, value|
                    unless paconfig[gov]['prodcost'] == 0
                      gov_bonus = buildable/(1+paconfig[gov]['prodcost'])
                      res_message += "\n#{gov}: #{number_nice(gov_bonus.round)}"
                    end
                  end
                  ship_factory = pscan[class_factory_table[ship.class_]]
                  if prod_res > 0 && ship_factory != 'None'
                    prod_modifier = prod_modifier_table[ship_factory]
                    ships_from_prod = (buildable + (prod_modifier * (prod_res/total_cost)))
                    res_message += "\nCounting #{number_nice(prod_res.round)} res in prod at #{ship_factory}"
                    paconfig['govs'].each do |gov, value|
                      unless paconfig[gov]['prodcost'] == 0
                        gov_bonus = ships_from_prod/(1+paconfig[gov]['prodcost'])
                        res_message += "\n#{gov}: #{number_nice(gov_bonus.round)}"
                      end
                    end
                  end
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: res_message)
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet scan for #{x}:#{y}:#{z}?")
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No ship named #{ship}?")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Planet #{x}:#{y}:#{z} can not be found")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is afford x.y.z ship")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is afford x.y.z ship")
        end
      end
    end

    on /^(\/|!|\+|.)xp/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        cmd, command, p1 = commands
        paconfig = YAML.load(IO.read('config/pa.yml'))
        case command
          when /[^\s]+\s[^\s]+/
            planetCoords = command.split(/(\d+)([. :\-])(\d+)(\2(\d+))/)
            planet = Planet.where(:x => planetCoords[1]).where(:y => planetCoords[3]).where(:z => planetCoords[5]).where(:active => true).first
            if planet
              attackCoords = p1.split(/(\d+)([. :\-])(\d+)(\2(\d+))/)
              attack = Planet.where(:x => attackCoords[1]).where(:y => attackCoords[3]).where(:z => attackCoords[5]).where(:active => true).first
              if attack
                xp = calc_xp(planet, attack)
                res_message = "Target #{planetCoords[1]}:#{planetCoords[3]}:#{planetCoords[5]} (#{number_nice(planet.value)}|#{number_nice(planet.score)}) | Attacker #{attackCoords[1]}:#{attackCoords[3]}:#{attackCoords[5]} (#{number_nice(attack.value)}|#{number_nice(attack.score)}) "
                res_message += "| Bravery: #{bravery(planet,attack)} | Roids: #{max_cap(planet, attack)} | XP: #{calc_xp(planet, attack)} | Score: #{xp*paconfig['xp_value']}"
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet found with #{attackCoords[1]}:#{attackCoords[3]}:#{attackCoords[5]} coords.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet found with #{planetCoords[1]}:#{planetCoords[3]}:#{planetCoords[5]} coords.")
            end
          when /[^\s]+/
            planetCoords = command.split(/(\d+)([. :\-])(\d+)(\2(\d+))/)
            planet = Planet.where(:x => planetCoords[1]).where(:y => planetCoords[3]).where(:z => planetCoords[5]).where(:active => true).first
            if planet
              sender = User.where(:chat_id => message.from.id).first
              attack = Planet.where(:id => sender.planet_id).first
              if attack
                xp = calc_xp(attack, planet)
                res_message = "Target #{planetCoords[1]}:#{planetCoords[3]}:#{planetCoords[5]} (#{number_nice(planet.value)}|#{number_nice(planet.score)}) | Attacker #{attack.x}:#{attack.y}:#{attack.z} (#{number_nice(attack.value)}|#{number_nice(attack.score)}) "
                res_message += "| Bravery: #{bravery(attack,planet).round} | Roids: #{max_cap(planet,attack).round} | XP: #{calc_xp(attack, planet).round} | Score: #{xp*paconfig['xp_value']}"
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have no planet set?")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet found with #{planetCoords[1]}:#{planetCoords[3]}:#{planetCoords[5]} coords.")
            end
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)value/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands[0] =~ /\A^.\Z/
          # need a better way... or a way that works!
          channel = message.chat.id
        else 
          channel = message.chat.id
        end
        cmd, planet, tick, *more = commands
        if planet == nil
          action = true
          user = User.where(:chat_id => message.from.id).first
          planet = Planet.where(:id => user.planet_id).first
        elsif planet.split(/:|\+|\./).length == 3
          x, y, z = planet.split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          action = true
        else
          action = false
        end
        if action == true
          if planet
            x = planet.x
            y = planet.y
            z = planet.z
            if commands.length < 3
              tick_now = Update.order(id: :desc).first
              if tick_now.id > 16
                tick_history = tick_now.id - 15
              else
                tick_history = 0
              end
              planet_ticks = PlanetHistory.where('tick <= ?', tick_now.id).where('tick >= ?', tick_history).where(:id => planet.id).order(tick: :desc)
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} value change:"
              planet_ticks.each do |planet_tick|
                res_message += "\npt#{number_nice(planet_tick.tick)} Value: #{number_nice(planet_tick.value)} (#{number_nice(planet_tick.vdiff)})  Roids: #{number_nice(planet_tick.size)} (#{planet_tick.rdiff})."
              end
              bot.api.send_message(chat_id: channel, text: "#{res_message}")
            elsif commands.length == 3
              planet_tick = PlanetHistory.where(:tick => tick.to_i).where(:id => planet.id).first
              if planet_tick
                bot.api.send_message(chat_id: channel, text: "Value: #{number_nice(planet_tick.value)} (#{number_nice(planet_tick.vdiff)})  Roids: #{number_nice(planet_tick.size)} (#{planet_tick.rdiff}) for #{planet.x}:#{planet.y}:#{planet.z} on pt#{number_nice(tick.to_i)}. ")
              else
                bot.api.send_message(chat_id: channel, text: "No data for tick #{tick}.")
              end
            else
              bot.api.send_message(chat_id: channel, text: "#{x}:#{y}:#{z} not found.")
            end
          else
            bot.api.send_message(chat_id: channel, text: "Command is value [x.y.z] <tick>.")
          end
        else
          bot.api.send_message(chat_id: channel, text: "You have insufficient access.")
        end
      end
    end

    on /^(\/|!|\+|.)unit/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'U').order(tick: :desc).first
            if scan
              uscans = UnitScan.where(:scan_id => scan.id).joins(:ships).select('ships.name as name, heresy_unitscan.amount as total')
              if uscans
                planet_history = PlanetHistory.where(:id => planet.id).where(:tick => scan.tick).first
                update = Update.order(id: :desc).first
                age = update.id - scan.tick
                value_diff = planet.value - planet_history.value
                res_message = "Unit Scan on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age}, value diff: #{value_diff})\n "
                uscans.each do |uscan|
                  res_message += "#{uscan.name} #{uscan.total} | "
                end
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Unit Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No Unit Scans of #{x}:#{y}:#{z} found")
            end           
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command: unit [x.y.z].")
        end
	end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)au/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length == 2
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'A').order(tick: :desc).first
            if scan
              uscans = UnitScan.where(:scan_id => scan.id).joins(:ships).select('ships.name as name, heresy_unitscan.amount as total')
              if uscans
                planet_history = PlanetHistory.where(:id => planet.id).where(:tick => scan.tick).first
                update = Update.order(id: :desc).first
                age = update.id - scan.tick
                value_diff = planet.value - planet_history.value
                res_message = "Advanced Unit Scan on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age}, value diff: #{value_diff})\n "
                uscans.each do |uscan|
                  res_message += "#{uscan.name} #{uscan.total} | "
                end
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Advanced Unit Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No Advanced Unit Scans of #{x}:#{y}:#{z} found")
            end           
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command: au [x.y.z].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
      end
    end

    on /^(\/|!|\+|.)top10/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        order_by = "score"
        race_search = ""
        alliance_search = ""
        commands.drop(1).each do |option|
          case option
            when /\Ascore/
              order_by = "score"
            when /\Avalue/
              order_by = "value"
            when /\Asize/
              order_by = "size"
            when /\Axp/
              order_by = "xp"
            when /\At/
              race_search = "Ter"
            when /\Acat/
              race_search = "Cat"
            when /\Axan/
              race_search = "Xan"
            when /\Azik/
              race_search = "Zik"
            when /\Aetd/
              race_search = "Etd"
            else
              alliance_search = option
          end
        end
        if alliance_search != ""
          alliance = Alliance.where("name ilike '%#{alliance_search}%'").first
          if alliance
            planets = Planet.joins("LEFT OUTER JOIN heresy_intel ON planet.id = heresy_intel.planet_id").where('heresy_intel.alliance_id = ?', alliance.id).select('planet.x, planet.y, planet.z, planet.score, planet.score_rank, heresy_intel.nick, heresy_intel.alliance_id, planet.value, planet.value_rank, planet.size, planet.size_rank, planet.xp, planet.xp_rank, planet.idle, planet.race')
            planets = planets.where(:race => race_search) if race_search != ""
            planets = planets.where('planet.active = true').order("#{order_by} desc").limit(10)
            if planets
              count = 0
              res_message = "Top #{alliance.name}#{race_search} planets by #{order_by}:"
              planets.each do |planet|
              count += 1
                res_message += "\n    ##{count} (#{planet.race}) Score: #{number_nice(planet.score)} (#{planet.score_rank}) Value #{number_nice(planet.value)} (#{planet.value_rank}) Size: #{number_nice(planet.size)} (#{planet.size_rank}) XP: #{number_nice(planet.xp)} (#{planet.xp_rank}) Coords: #{planet.x}:#{planet.y}:#{planet.z} Idle: #{planet.idle}"
                res_message += " Nick: #{planet.nick}" unless planet.nick == nil || planet.nick == ''
              end
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planets found for alliance #{alliance.name}.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No alliance found with name #{alliance_search}.")
          end
        else
          planets = Planet.joins("LEFT OUTER JOIN heresy_intel ON planet.id = heresy_intel.planet_id").select('planet.x, planet.y, planet.z, planet.score, planet.score_rank, heresy_intel.nick, heresy_intel.alliance_id, planet.value, planet.value_rank, planet.size, planet.size_rank, planet.xp, planet.xp_rank, planet.idle, planet.race')
          planets = planets.where(:race => race_search) if race_search != ""
          planets = planets.where('planet.active = true').order("#{order_by} desc").limit(10)
          if planets
            res_message = "Top #{race_search} planets by #{order_by}:"
            count = 0
            planets.each do |planet|
              count += 1
              res_message += "\n##{count} (#{planet.race}) Score: #{number_nice(planet.score)} (##{planet.score_rank}) Value #{number_nice(planet.value)} (##{planet.value_rank}) Size: #{number_nice(planet.size)} (##{planet.size_rank}) XP: #{number_nice(planet.xp)} (##{planet.xp_rank}) Coords: #{planet.x}:#{planet.y}:#{planet.z} Idle: #{planet.idle}"
              res_message += " Nick: #{planet.nick}" unless planet.nick == '' || planet.nick == ''
              unless planet.alliance_id == nil
                alliance = Alliance.where(:id => planet.alliance_id).first
                if alliance
                    res_message += " Alliance: #{alliance.name}" 
                end
              end
            end
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planets found for alliance #{alliance.name}.")
          end
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)spamin/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        cmd, ally_name = commands
        alliance = Alliance.where("name ilike '%#{ally_name.downcase}%'").first
        if alliance
          res_message = ""
          commands.drop(2).each do |coord|
            x,y,z = coord.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).first
            if planet
                intel = Intel.where(:planet_id => planet.id).first_or_create
                intel.alliance_id = alliance.id
                unless intel.save
                  res_message = "\nError, with #{x}:#{y}:#{z}\n"
                end
            else
              res_message = "\n#{x}:#{y}:#{z} doesn't exist\n"
            end
          end
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Planets set to #{alliance.name}\n#{res_message}.")
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Alliance #{commands[1]} not found?!.")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)spam/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          alliance = Alliance.where("name ilike '%#{commands[1].downcase}%'").first
          if alliance
            res_message = "\n"
            intels = Intel.where(:alliance_id => alliance.id)
            if intels
              intels.each do |intel|
                planet = Planet.where(:id => intel.planet_id).first
                if planet
                  res_message += "| #{planet.x}:#{planet.y}:#{planet.z} "
                end
              end
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Spam on alliance #{alliance.name} #{intels.count}/#{alliance.members}#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Alliance #{alliance.name} we have no data on!")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Alliance #{commands[1]} not found?!.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is spam [alliance].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)search/ do
        commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          intel = Intel.where("nick ilike '%#{commands[1].downcase}%'").first
          if intel
            planet = Planet.where(:id => intel.planet_id).first
            if planet
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} (#{planet.race}) '#{planet.rulername}' or '#{planet.planetname}'"
              res_message += "\nScore: #{planet.score} (#{planet.score_rank}) Value #{planet.value} (#{planet.value_rank}) Size: #{planet.size} (#{planet.size_rank}) XP: #{planet.xp} (#{planet.xp_rank}) Idle: #{planet.idle}\n "
              res_message += "\n    Nick:           #{intel.nick}" unless intel.nick == ''
              unless intel.alliance_id == nil
                alliance = Alliance.where(:id => intel.alliance_id).where(:active => true).first
                if alliance
                  res_message += "\n    Alliance:      #{alliance.name}"
                else
                  res_message += "\n    Alliance set with id ##{intel.alliance_id} but none found." 
                end
              end
              res_message += "\n    Fake nick:     #{intel.fakenick}" unless intel.fakenick == '' || intel.fakenick.nil?
              res_message += "\n    Gov:           #{intel.gov}" unless intel.gov == '' || intel.gov.nil?
              res_message += "\n    Defwhore:      #{intel.defwhore}" unless intel.defwhore == '' || intel.defwhore.nil?
              res_message += "\n    Amps:          #{intel.amps}" unless intel.amps == '' || intel.amps.nil?
              res_message += "\n    Dists:         #{intel.dists}" unless intel.dists == '' || intel.dists.nil?
              res_message += "\n    Comment:       #{intel.comment}" unless intel.comment == '' || intel.comment.nil?
              
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Planet not found for #{intel.name}?!")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{commands[1]} not found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is search [nick].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)seagal/ do
      paconfig = YAML.load(IO.read('config/pa.yml'))
      commands = @message.text.split(' ')
      if commands.length >= 2
        cmd, planet, num, *more = commands
        if planet.split(/:|\+|\./).length == 3
          x, y, z = planet.split(/:|\+|\./)
          p = Planet.where(:x => x).where(:y => y).where(:z => z).first
          if p
            user = User.where(:chat_id => message.from.id).first
            myp = Planet.where(:id => user.planet_id).first
            if myp
              resources = resources_per_agent(myp.value, p.value)
              res_message = "Your Seagals will ninja #{number_nice(resources)} resources from #{p.x}:#{p.y}:#{p.z} - 5: #{number_nice(resources*5)}, 10: #{number_nice(resources*10)}, 20: #{number_nice(resources*20)}."
              if num =~ /\A\d/
                res_message += "\nYou need #{number_nice((((num.to_f)*1000)/resources).ceil)} Seagals to ninja #{num.to_i}k res."
              end
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Can't find your planet?")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can't be found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: seagal [x.y.z] <sum>")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: seagal [x.y.z] <sum>")
      end
    end

    on /^(\/|!|\+|.)roidcost/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        if commands.length > 3
          cmd, roids, cost, bonus, *more = commands
          count = number_short(cost)
          paconfig = YAML.load(IO.read('config/pa.yml'))
          mining = paconfig['roids']['mining']
          if roids.to_i == 0
            return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Another connovar landing?")
          end
          mining = mining.to_i * ((bonus.to_f)+100)/100
          ship_value = paconfig['ship_value']
          ticks = (count.to_i * ship_value.to_i)/(roids.to_i*mining)
          res_message = "Capping #{roids} roids at #{number_nice(count.to_i)} value with #{bonus}% bonus will repay in #{ticks.round(2)} ticks (#{(ticks/24).round(2)} days)"
          paconfig['govs'].each do |gov, value|
            unless paconfig[gov]['prodcost'] == 0
              ticks_bonus = ticks * (1 + paconfig[gov]['prodcost'])
              res_message += "\n#{gov}: #{ticks_bonus.round(2)} ticks (#{(ticks_bonus/24).round(2)} days)" 
            end
          end
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: roidcost [roids] [value_cost] [mining_bonus]")
        end
      end
    end

    on /^(\/|!|\+|.)racism/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands[1] =~ /\A\d/
          x, y = commands[1].split(/:|\+|\./)
          galaxy = Galaxy.where(:x => x).where(:y => y).where(:active => true).first
          if galaxy
            planets = Planet.where(:x => x).where(:y => y).where('planet.active = true')
            planets = planets.select('sum(planet.value) as planet_value')
            planets = planets.select('sum(planet.score) as planet_score')
            planets = planets.select('sum(planet.size) as planet_size')
            planets = planets.select('sum(planet.xp) as planet_xp')
            planets = planets.select('planet.race as race')
            planets = planets.select('count(*) as members')
            planets = planets.group('planet.race')
            if planets
              res_message = "Demographics for #{x}:#{y}"
              planets.each do |planet|
                res_message += "\n#{planet.members} #{planet.race} Val(#{number_nice(planet.planet_value/planet.members)}) Score(#{number_nice(planet.planet_score/planet.members)}) Size(#{number_nice(planet.planet_size/planet.members)}) XP(#{number_nice(planet.planet_xp/planet.members)})"
              end
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planets for #{x}:#{y}?!")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No #{x}:#{y} galaxy doesn't exist.")
          end
        elsif commands[1] =~ /\A./
          alliance = Alliance.where("name ilike '%#{commands[1]}%'").first
          if alliance
            planets = Planet.joins(:intel).where('heresy_intel.alliance_id = ?', alliance.id).where('planet.active = true')
            planets = planets.select('sum(planet.value) as planet_value')
            planets = planets.select('sum(planet.score) as planet_score')
            planets = planets.select('sum(planet.size) as planet_size')
            planets = planets.select('sum(planet.xp) as planet_xp')
            planets = planets.select('planet.race as race')
            planets = planets.select('count(*) as members')
            planets = planets.group('planet.race')
            if planets
              res_message = "Demographics for #{alliance.name}:"
              planets.each do |planet|
                res_message += "\n#{planet.members} #{planet.race} Val(#{number_nice(planet.planet_value/planet.members)}) Score(#{number_nice(planet.planet_score/planet.members)}) Size(#{number_nice(planet.planet_size/planet.members)}) XP(#{number_nice(planet.planet_xp/planet.members)})"
              end
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No intel for alliance #{alliance.name}")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No alliance with name #{commands[1]}")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: racism [alliance|x.y]")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)news/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length == 2
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              scan = Scan.where(:planet_id => planet.id).where(:scantype => 'N').order(tick: :desc).first
              if scan
                return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "News Scan on #{x}:#{y}:#{z} pt.#{scan.tick} #{paconfig['viewscan']}#{scan.pa_id}")
              else
                return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No News Scans of #{x}:#{y}:#{z}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: news [x.y.z].")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: news [x.y.z].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)maxcap/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length == 3
          if commands[2].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            attacker = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            unless attacker
              return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
            end
          else
            return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is maxap [x.y.z] <x.y.z>.")
          end
        elsif commands.length == 1
          return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: maxcap [x.y.z] <x.y.z>")
        else
          user = User.where(:chat_id => message.from.id).first
          attacker = Planet.where(:id => user.planet_id).first
          unless attacker
            return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "no planet set.")
          end
        end
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          unless planet
            return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          return bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: maxcap [x.y.z] <x.y.z>")
        end
        max_cap = paconfig['roids']['maxcap']
        min_cap = paconfig['roids']['mincap']
        modifier = ((planet.value).to_f/(attacker.value).to_f)**0.5
        max = [min_cap, [(max_cap*modifier),max_cap].min].max
        total = 0
        waves = ""
        for i in 1..5 do
          cap = planet.size * max
          total += cap
          waves += "\n Wave #{i}: #{cap.to_i} #{total.to_i}"
          planet.size -= cap
        end
        res_message = "Caprate: #{(max*100).to_i}% #{waves}\nUsing attack: #{attacker.x}:#{attacker.y}:#{attacker.z}"
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)jgp/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length > 1
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              scan = Scan.where(:planet_id => planet.id).where(:scantype => 'J').order(tick: :desc).first
              if scan
                dscans = FleetScan.where(:scan_id => scan.id)
                if dscans
                  planet_history = PlanetHistory.where(:id => planet.id).where(:tick => scan.tick).first
                  update = Update.order(id: :desc).first
                  age = update.id - scan.tick
                  value_diff = planet.value - planet_history.value
                  res_message = "Jumpgate Probe on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age}, value diff: #{value_diff}))"
                  dscans.each do |dscan|
                      owner = Planet.where(:id => dscan.owner_id).first
                      eta = dscan.landing_tick - update.id
                      res_message += "\n(#{owner.x}:#{owner.y}:#{owner.z} #{dscan.fleet_name} | #{dscan.fleet_size} #{dscan.mission} #{eta})"
                  end
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Jumpgate Probe on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No Jumpgate Probes of #{x}:#{y}:#{z} found")
              end           
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "jgp [x.y.z].")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "jgp [x.y.z].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)loosecunts/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        users = User.joins(:epeni).select('name as name, rank as rank, penis as epenis').order("heresy_epenis.rank desc").limit(5)
        if users
          res_message = ""
          users.each do |user|
            res_message += "\n##{user.rank} #{user.name} #{number_nice(user.epenis)}"
          end
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Loose cunts: #{res_message}")
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no penis")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)links/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        bot_config = YAML.load(IO.read('config/stuff.yml'))
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{bot_config['url']} | #{bot_config['pa_link']} | #{bot_config['bcalc_link']} ")
      end
    end

    on /^(\/|!|\+|.)intel/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
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
                  res_message += "\n    Nick:           #{intel.nick}" unless intel.nick == ''
                  unless intel.alliance_id == nil
                    alliance = Alliance.where(:id => intel.alliance_id).where(:active => true).first
                    if alliance
                      res_message += "\n    Alliance:      #{alliance.name}"
                    else
                      res_message += "\n    Alliance set with id ##{intel.alliance_id} but none found." 
                    end
                  end
                  res_message += "\n    Fake nick:     #{intel.fakenick}" unless intel.fakenick == '' || intel.fakenick.nil?
                  res_message += "\n    Gov:           #{intel.gov}" unless intel.gov == '' || intel.gov.nil?
                  res_message += "\n    Defwhore:      #{intel.defwhore}" unless intel.defwhore == '' || intel.defwhore.nil?
                  res_message += "\n    Amps:          #{intel.amps}" unless intel.amps == '' || intel.amps.nil?
                  res_message += "\n    Dists:         #{intel.dists}" unless intel.dists == '' || intel.dists.nil?
                  res_message += "\n    Comment:       #{intel.comment}" unless intel.comment == '' || intel.comment.nil?
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Intel on #{x}:#{y}:#{z} #{res_message}")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No intel for #{x}:#{y}:#{z}, go get some!")
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
                      intel.nick = value
                      if intel.save
                        res_message += "\nNick set as #{value}"
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
                      bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: intel [x.z[.z]] [option=value]+")
                    end
                  end
                  if res_message.length > 0
                    bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} intel updated: #{res_message}")
                  end
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet exists for #{x}:#{y}:#{z}")
              end
            elsif planet.split(/:|\+|\./).length == 2
              x, y = planet.split(/:|\+|\./)
              if more.length == 0
                planets = Planet.where(:x => x).where(:y => y).where(:active => true).order(z: :asc)
                res_message = ""
                if planets
                  planets.each do |planet|
                    intel = Intel.where(:planet_id => planet.id).first
                    res_message += "\n#{planet.z}"
                    if intel
                      res_message += "\n    Nick:            #{intel.nick}" unless intel.nick == ''
                      unless intel.alliance_id == nil
                        alliance = Alliance.where(:id => intel.alliance_id).where(:active => true).first
                        if alliance
                          res_message += "\n    Alliance:      #{alliance.name}"
                        else
                          res_message += "\n    Alliance set with id ##{intel.alliance_id} but none found." 
                        end
                      end
                      res_message += "\n    Fake nick:     #{intel.fakenick}" unless intel.fakenick == '' || intel.fakenick.nil?
                      res_message += "\n    Gov:           #{intel.gov}" unless intel.gov == '' || intel.gov.nil?
                      res_message += "\n    Defwhore:      #{intel.defwhore}" unless intel.defwhore == '' || intel.defwhore.nil?
                      res_message += "\n    Amps:          #{intel.amps}" unless intel.amps == '' || intel.amps.nil?
                      res_message += "\n    Dists:         #{intel.dists}" unless intel.dists == '' || intel.dists.nil?
                      res_message += "\n    Comment:       #{intel.comment}" unless intel.comment == '' || intel.comment.nil?
                    else
                      res_message += "\n    N/A" 
                    end
                  end
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Information for planets in: #{x}:#{y}\n #{res_message}")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No galaxy exists for #{x}:#{y}")
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: intel [x.z[.z]] [option=value]+")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: intel [x.z[.z]] [option=value]+")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: intel [x.z[.z]] [option=value]+")
          end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)forcephone/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        if commands.length == 3
          cmd, user, phone = commands
          if phone =~ /\A\+/
            phone[0] = ''
          end
          user = User.where('LOWER(name) = ? OR LOWER(nick) = ?', user.downcase, user.downcase).first
          if user
            user.phone = phone
            user.pubphone = true
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Phone updated.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: forcesms [user] [phone number[44XXXXXXXXX]]")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)forceplanet/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        bot_config = YAML.load(IO.read('config/stuff.yml'))
        if commands.length == 3
          cmd, nick, planet = commands
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
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{user.name} planet is set as #{x}:#{y}:#{z}.")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no planet.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: forceplanet [user] [x.y.z]")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)exile/ do
      commands = @message.text.split(' ')
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
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planets?")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)edituser/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        if commands.length == 3
          cmd, nick, access = commands
          user = User.where(:name => nick).first
          if user
            user.name = nick
            user.active = true
            user.access = access
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User modified.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error adding, contact admin.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "They're not a member!")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: edituser [tg_username] [access]")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)dev/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'D').order(tick: :desc).first
            if scan
              dscan = DevScan.where(:scan_id => scan.id).first
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
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Development Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No Development Scans of #{x}:#{y}:#{z} found")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command: unit [x.y.z].")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)createbcalc/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands.length >= 3
          cmd, class_, *coords = commands
          total_fleets = 0
          errors = 0
          error_messages = ""
          res_message = ""
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
                uscans = Unitscan.where(:scan_id => scan.id).where("ships.class_ = '#{classes[class_]}'").joins(:ships).select('(ships.id - 1) as id, heresy_unitscan.amount as total')
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
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Following coords not found: #{error_messages}") unless errors == 0
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Following coords require scans: #{scans_missing_message}") unless scans_missing == 0
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not created as no fleets with that class found") if total_fleets == 0
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Class: #{class_} Coords: #{res_message} Link: #{bcalc}") unless total_fleets == 0
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "createbcalc [CLASS] [x.y.z].")
          end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)bumchums/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length < 3
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is bumchums [alliance] <alliance> [count].")
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
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Galaxies with at least #{number.to_i} bumchums from #{alliance.name} or #{alliance2.name}:\n #{coords}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No galaxies with at least #{number.to_i} bumchums from #{alliance.name} or #{alliance2.name}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{ally} or #{ally2} can't be found?")
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
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Galaxies with at least #{number.to_i} bumchums from #{alliance.name}:\n #{coords}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No galaxies with at least #{number.to_i} bumchums from #{alliance.name}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{ally} can't be found?")
            end
          end
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You have insufficient access.")
      end
    end

    on /^(\/|!|\+|.)bigdicks/ do
      if check_access(message.from.id, 100)
        users = User.joins(:epeni).select('name as name, rank as rank, penis as epenis').order("heresy_epenis.rank asc").limit(5)
        if users
          res_message = ""
          users.each do |user|
            res_message += "\n##{user.rank} #{user.name} #{number_nice(user.epenis)}"
          end
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Big Dicks: #{res_message}")
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no penis")
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)basher/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1] =~ /\A\d/
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              score = planet.score*paconfig['bash']['score']
              value = planet.value*paconfig['bash']['value']
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or above or score #{number_nice(score.round)} or above"
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet found for #{planet[1]}:#{planet[3]}:#{planet[5]}!")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command basher [x.y.z].")
          end
        else
          user = User.where(:chat_id => message.from.id).first
          planet = Planet.where(:id => user.planet_id).first
          if planet
            score = planet.score*paconfig['bash']['score']
            value = planet.value*paconfig['bash']['value']
            res_message = "#{planet.x}:#{planet.y}:#{planet.z} can hit planets with value #{number_nice(value.round)} or above or score #{number_nice(score.round)} or above"
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet set.")
          end
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)bashee/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1] =~ /\A\d/
          if commands[1].split(/:|\+|\./).length == 3
            x, y, z = commands[1].split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              score = planet.score/paconfig['bash']['score']
              value = planet.value/paconfig['bash']['value']
              res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or below or score #{number_nice(score.round)} or below"
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet found for #{planet[1]}:#{planet[3]}:#{planet[5]}!")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command bashee [x.y.z].")
          end
        else
          user = User.where(:chat_id => message.from.id).first
          planet = Planet.where(:id => user.planet_id).first
          if planet
            score = planet.score/paconfig['bash']['score']
            value = planet.value/paconfig['bash']['value']
            res_message = "#{planet.x}:#{planet.y}:#{planet.z} can be hit by planets with value #{number_nice(value.round)} or below or score #{number_nice(score.round)} or below"
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet set.")
          end
        end
      else
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You don't have enough access.")
      end
    end

    on /^(\/|!|\+|.)amps/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length == 2
          cmd, name, *more = commands
          if letter?(name)
            user = Intel.where(:nick => name).first
            if user
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{name} has #{user.amps} amps.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No user found.")
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
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}", parse_mode: 'HTML')
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No scanners found with more than #{name} amps.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: amps [nick|amps]")
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

            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Top 10 amp scanners\n#{res_message}", parse_mode: 'HTML')
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No scanners?")
          end
        end
      end
    end

    on /^(\/|!|\+|.)lookup/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
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
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No planet exists for #{x}:#{y}:#{z}")
          end
        elsif planet.split(/:|\+|\./).length == 2
          x, y = planet.split(/:|\+|\./)
            galaxy = Galaxy.where(:x => x).where(:y => y).where(:active => true).first
          if galaxy
            planet_count = Planet.where(:x => x).where(:y => y).count
            res_message = "#{x}:#{y} '#{galaxy.name}' (#{planet_count})"
            res_message += "Score: #{galaxy.score} (#{galaxy.score_rank}) Value: #{galaxy.value} (#{galaxy.value_rank}) Size: #{galaxy.size} (#{galaxy.size_rank}) XP: #{galaxy.xp} (#{galaxy.xp_rank})"
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No galaxy exists for #{x}:#{y}")
          end
        elsif planet =~ /\A./
          alliance = Alliance.where("name ilike '%#{planet}%'").where(:active => true).first
          if alliance
            res_message = "'#{alliance.name}' Members: #{alliance.members} (#{alliance.members_rank})"
            res_message += "Score: #{alliance.score} (#{alliance.score_rank}) Points: #{alliance.points} (#{alliance.points_rank}) Size: #{alliance.size} (#{alliance.size_rank}) Avg: #{alliance.size_avg} (#{alliance.size_avg_rank})"
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
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
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is lookup [x.y.z|x.y|ally_name]")
        end
      else
        user = User.where(:chat_id => message.from.id).first
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
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "You haven't set a planet?")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No user?")
        end
      end
      end
    end

    on /^(\/|!|\+|.)planet/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        paconfig = YAML.load(IO.read('config/pa.yml'))
        if commands[1].split(/:|\+|\./).length == 3
          x, y, z = commands[1].split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            scan = Scan.where(:planet_id => planet.id).where(:scantype => 'P').order(tick: :desc).first
            if scan
              pscan = PlanetScan.where(:scan_id => scan.id).first
              if pscan
                update = Update.order(id: :desc).first
                age = update.id - scan.tick
                res_message = "Planet Scan on #{x}:#{y}:#{z} (id: #{scan.pa_id}, pt: #{scan.tick}, age: #{age})"
                res_message += "\nRoids: m: #{number_nice(pscan.roid_metal)} c: #{number_nice(pscan.roid_crystal)} e: #{number_nice(pscan.roid_eonium)}"
                res_message += "\nResources: m:#{number_nice(pscan.res_metal)} c:#{number_nice(pscan.res_crystal)} e:#{number_nice(pscan.roid_eonium)}"
                res_message += "\nProd: #{number_nice(pscan.prod_res)} Selling: #{number_nice(pscan.sold_res)} Agents: #{number_nice(pscan.agents)} Guards: #{number_nice(pscan.guards)}"
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Planet Scan on #{x}:#{y}:#{z} #{paconfig['viewscan']}#{scan.pa_id}")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No Planet Scans of #{x}:#{y}:#{z} found")
            end
              
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{x}:#{y}:#{z} can not be found.")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "planet [x.y.z].")
        end
      end
    end
    
    on /^(\/|!|\+|.)tick/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        update = Update.order(id: :desc).first
        if commands.length == 2
          cmd, tick = commands
          if number?(tick)
            if update.id == tick.to_i
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{update.id} is current tick.")
            else
              tick_next = tick.to_i - update.id
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{tick} is in #{tick_next} ticks.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: tick <tick>")
          end
        else 
          if update
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{update.id} is current tick.")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Ticks haven't started yet.")
          end
        end
      end
    end

    on /^(\/|!|\+|.)help/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
        msg = "
  ` Help, for further details specify help [command]`
  ` All commands can be done in channel or in DM`
  ` --------------------------------------------`
  ` afford adduser amps au aually bashee basher `
  ` bigdicks bumchums call cost createbcalc dev `
  ` edituser eff forceplanet forcephone intel   `
  ` jgp jgpally links lookup loosecunts maxcap  `
  ` myplanet myphone news planet racism roidcost`
  ` seagal search ship sms smslog spam spamin   `
  ` stop top10 tick unit value xp               ` 
  ` --------------------------------------------`"
        bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{msg}", parse_mode: 'Markdown')
      end
    end

    on /^(\/|!|\+|.)call/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        if commands.length == 2
          user = User.where("LOWER(name) ilike '%#{commands[1].downcase}%' OR LOWER(nick) ilike '%#{commands[1].downcase}%%'")
          if user.count == 1
            user = user.first
            if user.phone != '' && user.phone != nil
              phone = user.phone.gsub('+', '')
              sender = User.where(:user_id => message.from.id).first
              bot_config = YAML.load(IO.read('config/stuff.yml'))
              account_sid = bot_config['twilio']['account_sid']
              auth_token = bot_config['twilio']['auth_token']
              @client = Twilio::REST::Client.new account_sid, auth_token
              @client.calls.create(
                from: bot_config['twilio']['number'],
                to: '+'+phone.to_s,
                  url: 'https://demo.twilio.com/welcome/voice/'
              )
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Calling #{user.name}.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{commands[1]} never set their phone number!!!.")
            end
          elsif user.count > 1
            users = user.map(&:name)
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Who are you trying to text: #{users.join(', ')}.")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No user found.")
          end
        end
      end
    end

    on /^(\/|!|\+|.)stop/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        if efficiency_args?(commands.drop(1).join(' '))
          cmd, number, ship, target = commands
          target = target || 't1'
          if target != 't1' || target != 't2' || target != 't3'
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: stop [number] [ship] [t1|t2|t3].")
          else
            target = target.downcase
            ship = Ships.where("lower(name) = '#{ship.downcase}'").first
            ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first if !ship
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
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No ship named #{ship}.")
            end
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: stop [number] [ship] [t1|t2|t3].")
        end
      end
    end

    on /^(\/|!|\+|.)sms/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 100)
        if commands.length >= 3
          cmd, user, *message_ = commands
          user = User.where("LOWER(name) ilike '%#{user.downcase}%' OR LOWER(nick) ilike '%#{user.downcase}%'")
          if user.count == 1
            user = user.first
            if user.phone != '' && user.phone != nil
              sender = User.where(:chat_id => message.from.id).first
              bot_config = YAML.load(IO.read('config/stuff.yml'))
              account_sid = bot_config['twilio']['account_sid']
              auth_token = bot_config['twilio']['auth_token']
              @client = Twilio::REST::Client.new account_sid, auth_token
              @client.messages.create(
                from: bot_config['twilio']['sms_number'],
                to: '+'+user.phone,
                body:  user.name + ': ' + message_.join(' ')
              )
              log = add_log(sender.id, user.user_id,'+'+user.phone, message_.join(' '))
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Message sent [##{log}]")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{user.name} never set their phone number!!!")
            end
          elsif user.count > 1
              users = user.map(&:name)
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Who are you trying to text: #{users.join(', ')}.")
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No user found.")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: sms [user] [message]")
        end
      end
    end

    on /^(\/|!|\+|.)adduser/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        if commands.length == 3
          cmd, nick, access = commands
          u = User.where("LOWER(name) ilike '%#{nick}%' OR LOWER(nick) ilike '%#{nick}%%'").first
          if u
            if u.active != true
              msg = add_user(u, access, nick, message.from.id)
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: msg)
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "They're already a member!")
            end
           else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User not found?")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: adduser [telegram_username] [access]")
        end
      end
    end

    on /^(\/|!|\+|.)setnick/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        if commands.length == 3
          cmd, nick, name = commands
          u = User.where("LOWER(name) = '#{nick.downcase}'").first
          if u
            u.nick = name
            if u.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User updated")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Contact admin")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User not found?")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: setnick [telegram_username] [irc_nick]")
        end
      end
    end

    on /^(\/|!|\+|.)setphone/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 1000)
        if commands.length == 3
          cmd, nick, phone = commands
          u = User.where("LOWER(name) = '#{nick.downcase}'").first
          if u
            u.phone = phone
            u.pubphone = true
            if u.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User updated")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Contact admin")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "User not found?")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: setphone [telegram_username] [phone number]")
        end
      end
    end

    on /^(\/|!|\+|.)mynick/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        if commands.length == 2
          cmd, nick = commands
          user = User.where(:chat_id => message.from.id).first
          if user
            user.nick = nick
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Nick updated.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
            end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: mynick [Nick]")
        end
      end
    end

    on /^(\/|!|\+|.)myphone/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        if commands.length == 2
          cmd, phone = commands
          user = User.where(:chat_id => message.from.id).first
          if user
            user.phone = phone
            user.pubphone = true
            if user.save
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Phone updated.")
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Not a user?")
            end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: myphone [phone number[44XXXXXXXXX]]")
        end
      end
    end

    on /^(\/|!|\+|.)myplanet/ do
      commands = @message.text.split(' ')
      if check_access(message.from.id, 0)
        bot_config = YAML.load(IO.read('config/stuff.yml'))
        if commands.length == 2
          cmd, planet = commands
          if planet.split(/:|\+|\./).length == 3
            x, y, z = planet.split(/:|\+|\./)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              user = User.where(:chat_id => message.from.id).where(:active => true).first
              intel = Intel.where(:planet_id => planet.id).first_or_create
              #alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
              alliance = Alliance.where(:name => user.ally).where(:active => true).first
              if intel && user && alliance
                intel.nick = user.nick
                intel.planet_id = planet.id
                user.planet_id = planet.id
                intel.alliance_id = alliance.id
                if intel.save && user.save
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Your planet is set as #{x}:#{y}:#{z}.")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
                end
              else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no planet.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: myplanet [x.y.z]")
          end
        elsif commands.length == 3
          cmd, x, y, z = commands
          if number?(x) && number?(y) && number?(z)
            planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
            if planet
              user = User.where(:chat_id => message.from.id).where(:active => true).first
              intel = Intel.where(:planet_id => planet.id).first_or_create
              alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
              if intel && user && alliance
                intel.nick = user.name
                intel.planet_id = planet.id
                user.planet_id = planet.id
                intel.alliance_id = alliance.id
                if intel.save && user.save
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Your planet is set at #{x}:#{y}:#{z}.")
                else
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
                end
              else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Error, contact admin.")
              end
            else
              bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no planet.")
            end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "There is no planet.")
          end
        else 
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: myplanet [x.y.z]")
        end
      end
    end

    on /^(\/|!|\+|.)ship/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
        if commands.length == 2
          cmd, ship_ = commands
          ship = Ships.where("lower(name) = '#{ship.downcase}'").first
          ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first if !ship
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
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: res_message)
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No ship named #{ship}]")
          end
        else 
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: ship [ship]")
        end
      end
    end

    on /^(\/|!|\+|.)cost/ do
      if check_access(message.from.id, 0)
      commands = @message.text.split(' ')
        if commands.length == 3
            cmd, count, ship = commands
            ship = Ships.where("lower(name) = '#{ship.downcase}'").first
            ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first if !ship
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
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
            else
                bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No ship named #{ship}")
            end
        else 
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command is: cost [number] [ship]")
        end
      end
    end

    on /^(\/|!|\+|.)eff/ do
      if check_access(message.from.id, 0)
        commands = @message.text.split(' ')
        if commands.length >= 3
          command, number, ship, target = commands
          target = target || 't1'
          puts target
          target = target.downcase
          ship = Ships.where("lower(name) = '#{ship.downcase}'").first
          ship = Ships.where("lower(name) like '%#{ship.downcase}%'").first if !ship
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
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
              elsif ship.t1 == 'Roids'
                  captured = total_damage/50
                  roid_value = paconfig['roid_value'].to_i
                  roid_value_lost = (captured * roid_value).round
                  res_message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) will capture #{number_nice(captured.floor)} (#{number_nice(roid_value_lost.floor)}) asteroids"
                  bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
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
                      bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{res_message}")
                  else
                      bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "#{ship} has no targets for class #{target_class}")
                  end
              end
          else
            bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "No ship named #{ship}")
          end
        else
          bot.api.send_message(chat_id: chat_user(message.chat.id, commands), text: "Command: /eff [number] [ship] [t1|t2|t3]")
        end
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
    user.ally = 'Heresy'
    if user.save
      response = "User added."
    else
      response = "Error adding, contact admin."
    end
    return response
  end

  def add_ult(user, access, nick, name)
    user.active = true
    user.access = access
    user.nick = nick
    user.ally = 'Ultores'
    if user.save
      response = "Ultores user added."
    else
      response = "Error adding, contact admin."
    end
    return response
  end

  def add_vgn(user, access, nick, name)
    user.active = true
    user.access = access
    user.nick = nick
    user.ally = 'VGN'
    if user.save
      response = "VGN user added."
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
    modifier = (planet.value/target.value)*0.5
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
    user = User.where(:user_telegram_chat_id => user).first
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

  def resources_per_agent(value,target)
    paconfig = YAML.load(IO.read('config/pa.yml'))
    res = paconfig['res_cap_per_agent']
    return [res,(target * 2000)/value].min
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
