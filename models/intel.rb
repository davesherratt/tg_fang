require 'active_record'

class Intel < ActiveRecord::Base
	self.table_name = 'heresy_intel'

  def amps        
    if (val=self[:amps]).empty?
      0
    else
      val
    end
  end


  def nick        
    if (val=self[:nick]).empty?
      "N/A"
    else
      val
    end
  end
end
