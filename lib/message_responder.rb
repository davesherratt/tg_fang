require './models/user'
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
    messages = @message.split(' ')
    
    on /^\/eff/ do
      command number, ship, target = commands
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
              message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) will destroy #{number_nice(destroyed.floor)} (#{number_nice(destroy_spec.floor)}) structures."
          elsif ship.t1 == 'Roids'
              captured = total_damage/50
              roid_value = paconfig['roid_value'].to_i
              roid_value_lost = (captured * roid_value).round
              message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) will capture #{number_nice(captured.floor)} (#{number_nice(roid_value_lost.floor)}) asteroids"
              MessageSender.new(bot: bot, chat: message.chat, text: "#{message}").send
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
                  message = "#{number_nice(number)} #{ship.name} (#{number_nice(ship_total_value.floor)}) targetting #{target_class} will #{attack}"
                  targets.each do |target|
                      if ship.type_.downcase == "emp"
                          destroyed = ((efficiency * (ship.guns.to_i*number.to_i)*(100-target.empres.to_i))/100).round
                      else
                          destroyed = ((efficiency * total_damage)/target.armor.to_i)
                      end
                      value_lost = ((target.total_cost.to_i*destroyed)/ship_value)
                      message += "#{target.name}: #{number_nice(destroyed.floor)} (#{number_nice(value_lost.floor)}) "
                  end
                  MessageSender.new(bot: bot, chat: message.chat, text: "#{message}").send
              else
                  MessageSender.new(bot: bot, chat: message.chat, text: "#{ship} has no targets for class #{target_class}").send
              end
          end
      else
        MessageSender.new(bot: bot, chat: message.chat, text: "No ship named #{ship}").send
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
