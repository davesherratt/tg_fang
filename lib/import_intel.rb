load 'Rakefile'
require 'active_record'
require 'telegram/bot'
require './app/models/user'
require './app/models/alliance'
require './app/models/planet'
require './app/models/update'
require './app/models/intel'
require 'active_support/core_ext/hash' 
require 'nokogiri'

configuration = YAML::load(IO.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(configuration)

Nokogiri::XML(File.open(ARGV[0])).xpath("//entry").each do |h|

	alliance = h.at("alliance").text
       	coords = h.at("coords").text
	if alliance != nil && coords != nil
		a = Alliance.where("name ilike '%#{alliance}%'").first
		if a 
			x,y,z = coords.split(/:|\+|\./)
			planet = Planet.where(:x => x).where(:y => y).where(:z => z).first
			if planet
				intel = Intel.where(:planet_id => planet.id).first_or_create
				if intel
					intel.alliance_id = a.id
					if intel.save
					end
				end
			end
		end
	end
end
