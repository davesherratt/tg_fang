require 'active_record'

class Request < ActiveRecord::Base
	self.table_name = 'heresy_request'
end
