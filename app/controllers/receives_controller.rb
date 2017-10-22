require 'mail'
require "base64"
require 'fog/aws'
class ReceivesController < ApplicationController
   protect_from_forgery with: :null_session

   def index
     puts 'hello world'
   end

  def create
    notification = Hashie::Mash.new JSON.parse(request.raw_post)
    case notification.Type
      when "SubscriptionConfirmation"
       confirm(notification.TopicArn, notification.Token)
      when "Notification"
        #SNSNotificationModel.create(:msg notification.Message)
        mail = Hashie::Mash.new JSON.parse(notification.Message)
        destination = mail.mail.destination[0]
        subject = mail['mail']['commonHeaders']['subject']
puts destination
puts mail.to_yaml
        message = Mail.read_from_string(Base64.decode64(mail['content']))
        puts text_part(message)
        body = text_part(message)
#        Rails.logger.error "Destination #{mail.mail.destination[0]}"
#       	Rails.logger.error "Contents Coded #{mail.content}"
#        Rails.logger.error "Contents Decoded #{message}"
        Rails.logger.error "Contents Decoded #{body}"
    	userName = destination.split('@')
	user = User.where("nick ilike '%#{userName[0]}%'").first
        if user
puts user.to_yaml
		puts user.to_yaml
		new_fleets = body.scan(/We have detected an open jumpgate from (.+), located at (\d{1,2}):(\d{1,2}):(\d{1,2}).\s+The\s+fleet\s+will\s+approach\s+our\s+system\s+in tick (\d+) and appears to have (\d+) visible ships./)
		recalls = body.scan(/The (.+) fleet from (\d{1,2}):(\d{1,2}):(\d{1,2}) has been recalled./)
		constructions = body.scan(/Our construction team reports that .+ has been finished/)
		researchs = body.scan(/Our scientists report that .+ has been finished/)
puts recalls
puts new_fleets
		researchs.each do |research|
	   	notification = Notification.create!(
      				user_id: user.id,
      				message: research,
	      			subject: subject,
	      			type_: 'Research'
  			)
	    	end

			constructions.each do |construction|
			    	notification = Notification.create!(
	      				user_id: user.id,
	      				message: construction,
		      			subject: subject,
		      			type_: 'Construction'
	    			)
	    		end

			recalls.each do |recall|
			    	notification = Notification.create!(
	      				user_id: user.id,
	      				message: recall,
					x: recall[1],
                                        y: recall[2],
                                        z: recall[3],
                                        fleet_name: recall[0].gsub(/\s+/, ' '),
		      			subject: subject,
		      			type_: 'Recall'
	    			)
	    		end

	    		new_fleets.each do |new_fleet|
				msg = new_fleet.reject { |c| c.empty? } - ['', nil, ' ', ', ', '\n', '\\n']
			    	notification = Notification.create!(
	      				user_id: user.id,
	      				message: new_fleet,
		      			subject: subject,
					x: msg[1],
                                        y: msg[2],
                                        z: msg[3],
                                        ship_count: msg[5],
                                        lt: msg[4],
                                        fleet_name: msg[0].gsub(/\s+/, ' '),
		      			type_: 'NewFleet'
	    			)
	    		end
		end
      else
        Rails.logger.error "Unknown notification type #{notification.Type}"
    end
puts request.raw_post
    render nothing: true
  end

  private

    def confirm(arn, token)
       sns = Fog::AWS::SNS.new(
                               aws_access_key_id: Aws.config[:key],
                               aws_secret_access_key: Aws.config[:secret],
                               region_name: Aws.config[:region]
                             )
       sns.confirm_subscription(arn, token)
    end

      def multipart?(message)
        message.parts.count > 0
      end

      def text_part(message)
        multipart?(message) ? message.text_part.body.to_s : message.body.to_s
      end

    def receife_params
      params.fetch(:receife, {})
    end
end
