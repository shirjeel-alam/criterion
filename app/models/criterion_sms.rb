# == Schema Information
#
# Table name: criterion_sms
#
#  id            :integer(4)      not null, primary key
#  to            :string(255)
#  message       :text
#  sender_id     :integer(4)
#  sender_type   :string(255)
#  receiver_id   :integer(4)
#  receiver_type :string(255)
#  status        :boolean(1)
#  created_at    :datetime
#  updated_at    :datetime
#

class CriterionSms < ActiveRecord::Base
	API_KEY = 'cc733a1ee374fa37453e'
	DEFAULT_VALID_MOBILE_NUMBER = '03222463936'

	belongs_to :sender, polymorphic: true
	belongs_to :receiver, polymorphic: true

	before_validation :strip_to
	before_create :associate_receiver
	# after_create :send_sms

	validates :to, presence: true, numericality: true, length: { is: 11 }, format: { with: /^03\d{9}$/ }
	validates :message, presence: true, length: { maximum: 300 }

	def successful?
		status
	end

  ### View Helpers ###

  def status_label
    status ? 'Sent' : 'Failed'
  end

  def status_tag
    status ? :ok : :error
  end

	private
	def strip_to
		self.to = to.strip
	end

	def associate_receiver
		self.receiver = (PhoneNumber.find_by_number(to).contactable rescue nil) unless receiver.present?
	end

	def send_sms
		http = Net::HTTP.new('api.sendsms.pk')
		request = Net::HTTP::Post.new("/sendsms/#{API_KEY}.json")
		request.set_form_data(phone: to, msg: message, type: 0)
		response = http.request(request)

		result = ActiveSupport::JSON.decode(response.body)['result']
		if result == 'true'
			update_attribute(:status, true)
		elsif result == 'false'
			update_attribute(:status, false)
		else
			raise 'Unknown Response SendSMS PK'
		end
	end

	def extra
	end
end
