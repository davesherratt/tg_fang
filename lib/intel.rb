require 'open-uri'
require 'json'
require '/heresy/tg_fang/app/models/alliance.rb'
require '/heresy/tg_fang/app/models/planet.rb'
require '/heresy/tg_fang/app/models/intel.rb'

download = open('http://breampatools.ddns.net/PA/intel_out.php?pla=fjkhGUYgdf')
file = "intel#{Time.now.to_i}"
IO.copy_stream(download, file)
read_file = File.read(file)
data_hash = JSON.parse(read_file)
ActiveRecord::Base.establish_connection("postgres://postgres@localhost/merlin?pool=5")
if data_hash['planets']
	puts "Loading tick #{data_hash['tick']} Intel"
	data_hash['planets'].each do |p|
		unless p[1] == nil
			unless p[1]['alliance'] == nil
				ally = Alliance.where("name ilike '%#{p[1]['alliance']}%'").first
				if ally
					x, y, z = p[0].split(/:|\+|\./)
					planet = Planet.where(:x => x).where(:y => y).where(:z => z).first
					if planet
				                intel = Intel.where(:planet_id => planet.id).first_or_create
		        		        intel.alliance_id = ally.id
		                		unless intel.save
		                  			puts "Error, with #{x}:#{y}:#{z}\n"
		                		end
					end
				else
					puts "#{p[1]['alliance']} doesn't exist"
				end
			else
				x, y, z = p[0].split(/:|\+|\./)
	                        p = Planet.where(:x => x).where(:y => y).where(:z => z).first
	                        if p
	                        	intel = Intel.where(:planet_id => p.id).first_or_create
	                                intel.alliance_id = nil
	                                unless intel.save
	                                	puts "Error, with #{x}:#{y}:#{z}\n"
	                              	end
	                        end
			end
			unless p[1]['nick'] == nil
				x, y, z = p[0].split(/:|\+|\./)
				planet = Planet.where(:x => x).where(:y => y).where(:z => z).first
				if planet
	                intel = Intel.where(:planet_id => planet.id).first_or_create
			        intel.nick = p[1]['nick']
	        		unless intel.save
	          			puts "Error, with #{x}:#{y}:#{z}\n"
	        		end
				end
			end
		end
	end
	puts "Data updated."
end
File.delete(file)