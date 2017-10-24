class PlanetController < ApplicationController
   protect_from_forgery with: :null_session

   def index
     puts 'hello world'
   end

private
    def planet_params
      params.fetch(:planet, {})
    end
end
