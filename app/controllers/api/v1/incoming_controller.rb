class Api::V1::IncomingController < Api::V1::BaseController
	protect_from_forgery with: :null_session
	respond_to :json

	def create
		tick = Update.select('id','defence_check').order(id: :desc).first
		if tick.defence_check == false
			params['data'].each do |incoming|
						
				inc = Incoming.new
				repeat = Incoming.where(:attacker_coords => incoming['attackerCoords'])
								.where(:fleet_count => incoming['fleetSize'])
								.where(:target_coords => incoming['targetCoords'])
								.where(:org_eta => incoming['orgEta'])
								.where('CAST(eta AS INT) > ?', incoming['eta'].to_i)
								.where(:fleet_name => incoming['fleetName']).first
				inc.fleet_id = repeat.fleet_id if repeat
				inc.attacker_coords = incoming['attackerCoords']
				attacker_x, attacker_y, attacker_z = incoming['attackerCoords'].split(' ').first.split(':')
				inc.attacker_x = attacker_x
				inc.attacker_y = attacker_y
				inc.attacker_z = attacker_z
				inc.org_eta = incoming['orgEta']
				inc.eta = incoming['eta']
				inc.fleet_name = incoming['fleetName']
				inc.fleet_count = incoming['fleetSize']
				inc.incoming_class = incoming['fleetType']
				inc.target_coords = incoming['targetCoords']
				target_x, target_y, target_z = incoming['targetCoords'].split(' ').first.split(':')
				inc.target_x = target_x
				inc.target_y = target_z
				inc.target_z = target_z
				inc.tick = tick.id
				inc.fleet_type = case incoming['fleetType'].split(' ').first
					when 'mission_attack'
						'Attack'
					when 'mission_return'
						'Recall'
					else
						'UNKNOWN'
				end
				inc.war = incoming['fleetType'].split(' ')[1] == 'relations_war' ? true : false
				planet = Planet.select(:id).where(:x => attacker_x).where(:y => attacker_y).where(:z => attacker_z).first
				if planet
					intel = Intel.where(:planet_id => planet.id).first
					if intel
						alliance = Alliance.where(:id => intel.alliance_id).first
						if alliance
							inc.ally = alliance.name
						end
					end
				end
				if inc.save
					p 'ok'
					p incoming.to_yaml
				else
					p 'error'
					p incoming.to_yaml
				end
			end
			tick.defence_check = true
			tick.save
		end
	end

	private
	def incoming_params
		params.require(:incoming).permit(:id)
	end

end
