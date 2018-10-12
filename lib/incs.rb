#!/usr/bin/env ruby
Dir.chdir "/heresy/tg_fang/"
load 'Rakefile'
require 'active_record'
require '/heresy/tg_fang/app/models/incoming.rb'
require '/heresy/tg_fang/app/models/incs_peep.rb'
require '/heresy/tg_fang/app/models/incs_data.rb'

configuration = YAML::load(IO.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(configuration)

ids = result = ActiveRecord::Base.connection.exec_query('select id
from (
    select id,
           rank() over (partition by fleet_id order by created_at asc) as rank
    from incoming
) as dt
where rank = 1')

incs = Incoming.where(:id => ids.pluck('id')).select("count(*) as total, ally, to_char(created_at, 'YYYY-MM-DD') as day").group("to_char(created_at, 'YYYY-MM-DD'), ally").order("to_char(created_at, 'YYYY-MM-DD') desc")
IncsData.delete_all
incs.each do |inc|
	i = IncsData.new
	i.date = inc.day
	i.ally = inc.ally
    i.incs = inc.total
	if i.save
	else
		puts 'issue with '+inc.day 
	end
end

peeps = Incoming.where(:id => ids.pluck('id')).select("count(*) as total, attacker_x, attacker_y, attacker_z, ally, to_char(created_at, 'YYYY-MM-DD') as day").group("to_char(created_at, 'YYYY-MM-DD'), attacker_x, attacker_y, attacker_z, ally").order("to_char(created_at, 'YYYY-MM-DD') desc")
IncsPeep.delete_all
peeps.each do |peep|
	i = IncsPeep.new
	i.date = peep.day
	i.ally = peep.ally
    i.incs = peep.total
    i.attacker_x = peep.attacker_x
    i.attacker_y = peep.attacker_y
    i.attacker_z = peep.attacker_z
	if i.save
	else
		puts 'issue with '+peep.day 
	end
end

