# == Schema Information
#
# Table name: criterion_sms
#
#  id            :integer          not null, primary key
#  to            :string(255)
#  message       :text
#  sender_id     :integer
#  sender_type   :string(255)
#  receiver_id   :integer
#  receiver_type :string(255)
#  status        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  api_response  :text
#

class CriterionSms < ActiveRecord::Base
  attr_accessor :extra
  
	API_KEY = 'b84b75daddef4d7db570'
	DEFAULT_VALID_MOBILE_NUMBER = '03132100200'

	belongs_to :sender, polymorphic: true
	belongs_to :receiver, polymorphic: true

	before_validation :strip_to
	before_create :associate_receiver
	after_create :send_sms

	validates :message, presence: true, length: { maximum: 262 }

  scope :sent, where(status: true)
  scope :failed, where(status: false)

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

    decoded_response = ActiveSupport::JSON.decode(response.body)
    result = decoded_response['result']
    api_response = decoded_response['message']

		if result == 'true'
			update_attributes(status: true, api_response: api_response)
		elsif result == 'false'
			update_attributes(status: false, api_response: api_response)
		else
			raise 'Unknown Response SendSMS PK'
		end
	end
end
