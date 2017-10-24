require 'active_record'

class Alliance < ActiveRecord::Base
    self.table_name = 'alliance'
    has_many :intel
end
