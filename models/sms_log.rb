require 'active_record'

class SmsLog < ActiveRecord::Base
	self.table_name = 'heresy_sms_log'
end

