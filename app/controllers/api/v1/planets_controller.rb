class Api::V1::PlanetsController < Api::V1::BaseController 
	def index 
		#respond_with Planet.joins(:intel).joins(:alliance).select('planet.*, heresy_intel.*, alliance').order(score_rank: :asc).limit(100)
		respond_with Planet
			.left_outer_joins(:intel, :alliance)
			.select('planet.id, planet.score_rank, planet.x, planet.y, planet.z, planet.score, planet.size, planet.race, planet.planetname, planet.rulername, alliance.name')
			.order(score_rank: :asc)
#			.limit(100)
		#puts Planet.joins(:intel).joins(:alliance)
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
