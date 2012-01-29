class CriterionSms < ActiveRecord::Base
	API_KEY = 'cc733a1ee374fa37453e'
	DEFAULT_VALID_MOBILE_NUMBER = '03222463936'

	belongs_to :sender, :polymorphic => true
	belongs_to :receiver, :polymorphic => true

	before_validation :strip_to
	before_create :associate_receiver
	after_create :send_sms

	validates :to, :presence => true, :numericality => true, :length => { :is => 11 }, :format => { :with => /^03\d{9}$/ }
	validates :message, :presence => true, :length => { :maximum => 300 }

	def successful?
		status
	end

	private
	def strip_to
		self.to = to.strip
	end

	def associate_receiver
		self.receiver = PhoneNumber.find_by_number(to).contactable rescue nil
	end

	def send_sms
		http = Net::HTTP.new('api.sendsms.pk')
		request = Net::HTTP::Post.new("/sendsms/#{API_KEY}.json")
		request.set_form_data(:phone => to, :msg => message, :type => 0)
		response = http.request(request)

		if response.body == 'true'
			update_attribute(:status, true)
		else
			update_attribute(:status, false)
		end
	end

	def extra
	end
end
