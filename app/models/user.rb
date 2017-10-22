require 'active_record'

class User < ActiveRecord::Base
	self.table_name = 'heresy_users'
	has_many :epeni
end
