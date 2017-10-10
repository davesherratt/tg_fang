require './models/user'
require './models/planet'
require './models/attack_target'
require './models/ships'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
  end

  def respond
    on /^\/cost/ do

      if commands.length == 2
          count, ship, *more = arguments
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
                      message += " #{paconfig[gov.first]['name']}: #{number_nice((metal.floor))} metal, #{number_nice((crystal.floor))} crystal and #{number_nice((eonium.floor))} eonium"
                  end
              end
              value = (ship.total_cost.to_i * count.to_i) * (1.0/ship_value - 1.0/res_value)
              res_message += " It will add #{value.floor} value."
              MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} #{res_message}").send
          else
              send_message data.channel, "<@#{data.user}>: No ship named #{ship}
              MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} No ship named #{ship}").send
          end
      else 
          MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} Command is: cost [number] [ship]").send
      end
    end

    on /^\/eff/ do
      commands = @message.text.split(' ')
      if commands.length >= 3
        command, number, ship, target = commands
        target = target || 't1'
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
                MessageSender.new(bot: bot, chat: message.chat, text: "#{res_message}").send
            else
                target_class = ship["#{target}"]
                targets = Ships.where(:class_ => target_class)
                unless targets.empty?
                    if ship.type_.downcase == "norm" || ship.type_.downcase == "cloak"
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
                    MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} #{res_message}").send
                else
                    MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} #{ship} has no targets for class #{target_class}").send
                end
            end
        else
          MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} No ship named #{ship}").send
        end
      else
        MessageSender.new(bot: bot, chat: message.chat, text: "@#{@message.from} Command: /eff [number] [ship] [t1|t2|t3]").send
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
    user = User.where(:slack_id => user).first
    if user.access >= access
      return true
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

  def generateScanUrl(type,x,y,z,pa_scan_type)
    paconfig = YAML.load(IO.read('config/pa.yml'))
    if type == 'single'
      url = paconfig['reqscan'].gsub('TTT', "#{pa_scan_type}").gsub('XXX', "#{x}").gsub('YYY', "#{y}").gsub('ZZZ', "#{z}")
    end
    return url
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
