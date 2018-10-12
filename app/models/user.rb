require 'active_record'

class User < ActiveRecord::Base
	self.table_name = 'phpbb_users'
	has_many :epeni

	#devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
end
