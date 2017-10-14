require 'active_record'

class Intel < ActiveRecord::Base
	self.table_name = 'heresy_intel'

  def amps        
    if (val=self[:amps]).nil?
      0
    else
      val
    end
  end


  def nick        
    if (val=self[:nick]).nil?
      "N/A"
    else
      val
    end
  end
end
