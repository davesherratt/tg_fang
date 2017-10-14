require './models/user'
require './models/alliance'
require './models/planet'
require './models/attack_target'
require './models/ships'
require './models/update'
require './models/intel'
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
    on /^\/tick/ do
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
          bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: "")
      end
    end

    on /^\/help/ do
      msg = "# Help, for further details specify help [command]
      ### All commands can be done in channel or in DM.
      ------------------
      - adduser adopt amps attack au aually bashee basher bigdicks book bumchums call cost createbcalc dev edituser editattack
      - eff emo forcepass forceplanet forcesms fuckthatname getanewdaddy hi intel jgp jgpally links
      - lookup loosecunts maxcap myamps myplanet news planet racism remuser req roidcost seagal search setpass setsms ship
      - sms smslog spam spamin stop top10 tick unit unbook value whois xp
      ------------------"
      #bot.api.send_message(chat_id: message.chat.id, reply_to_message_id: message.message_id, text: msg, reply_markup: reply_markup(msg))
    end

    on /^\/call/ do
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

    on /^\/stop/ do
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

    on /^\/sms/ do
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

    on /^\/adduser/ do
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

    on /^\/setnick/ do
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

    on /^\/setphone/ do
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

    on /^\/mynick/ do
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

    on /^\/myphone/ do
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

    on /^\/myplanet/ do
      commands = @message.text.split(' ')
      bot_config = YAML.load(IO.read('config/stuff.yml'))
      if commands.length == 2
        cmd, planet = commands
        if planet.split(/:|\+|\./).length == 3
          x, y, z = planet.split(/:|\+|\./)
          planet = Planet.where(:x => x).where(:y => y).where(:z => z).where(:active => true).first
          if planet
            user = User.where(:id => message.from.id).where(:active => true).first
puts 'p:'+planet.id
puts message.from.id
            intel = Intel.where(:planet_id => planet.id).first_or_create
puts 'i:'+intel.id
            alliance = Alliance.where(:name => bot_config['alliance']).where(:active => true).first
puts 'a:'+alliance.id.to_s
            if intel && user && alliance
              intel.nick = user.name
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

    on /^\/ship/ do
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

    on /^\/cost/ do
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

    on /^\/eff/ do
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
    check =~ /\A[^A-Za-z$]+\Z/
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

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
