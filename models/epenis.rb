require 'active_record'
class Epenis < ActiveRecord::Base
  self.table_name = "heresy_epenis"
  belongs_to :heresy_user
end
