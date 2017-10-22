require 'active_record'
class UnitScan < ActiveRecord::Base
  self.table_name = "heresy_unitscan"
  belongs_to :scan
  belongs_to :ships, :foreign_key => "ship_id"
end
