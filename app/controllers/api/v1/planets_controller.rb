class Api::V1::PlanetsController < Api::V1::BaseController
	protect_from_forgery with: :null_session 
	def index 
		planets = Planet
			.left_outer_joins(:intel, :alliance)
			.select('planet.id, planet.score_rank, planet.value_rank, planet.size_rank, planet.xp_rank, planet.value, planet.xp, 
				planet.ratio, planet.size_growth, planet.score_growth, planet.value_growth, planet.value_growth, heresy_intel.nick, planet.x, planet.y, planet.z, planet.score, planet.size, planet.race, planet.planetname, planet.rulername, alliance.name')
			.order(score_rank: :asc)
#			.limit(100)
		if planets
			respond_with json: planets, status: 200
		else
			respond_with json: { errors: 'No planets?' }, status: 422
		end

	end

	def p
		p = Planet.where(:x => params[:x]).where(:y => params[:y]).where(:z => params[:z])
			.left_outer_joins(:intel, :alliance)
			.select('planet.id, planet.score_rank, planet.value_rank, planet.size_rank, planet.xp_rank, planet.value, planet.xp, planet.ratio, planet.size_growth_pc, planet.score_growth_pc, planet.value_growth_pc, heresy_intel.nick, planet.x, planet.y, planet.z, planet.score, planet.size, planet.race, planet.planetname, planet.rulername, alliance.name')
			.first
		if p
			history = PlanetHistory.where(:id => p.id).order(tick: :desc)
			respond_with data: { details: p, history: history}, status: 200
		else
			respond_with json: { errors: 'Planet not found' }, status: 422
		end
	end

	def update 
		planet = Planet.find(params["id"]) 
		planet.update_attributes(item_params) 
		respond_with item, json: planet 
	end 

	private 
	def planet_params 
		params.require(:planet).permit(:id) 
	end

end
