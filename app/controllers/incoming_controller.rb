class Incomingontroller < ApplicationController 
   	protect_from_forgery with: :null_session
	def index 
		puts params
	end 
end
