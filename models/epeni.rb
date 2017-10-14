require 'active_record'
class Epeni < ActiveRecord::Base
  self.table_name = "heresy_epenis"
  belongs_to :heresy_user
end
