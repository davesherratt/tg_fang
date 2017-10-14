require 'active_record'
class Unitscan < ActiveRecord::Base
  self.table_name = "fang_unitscan"
  belongs_to :scan
  belongs_to :ships, :foreign_key => "ship_id"
end
