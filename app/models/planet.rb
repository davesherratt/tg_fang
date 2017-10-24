require 'active_record'

class Planet < ActiveRecord::Base
    self.table_name = 'planet'
    has_many :intel
    has_many :alliance, :through => :intel
end
