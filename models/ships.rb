require 'active_record'

class Ships < ActiveRecord::Base
	def name= name
  		super(name.try(:downcase))
	end
end
