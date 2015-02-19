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
  
  # SendSMS.pk
	# API_KEY = '0eda5d8d442df99f3608'

  # SMSCenter.pk
  # API_KEY = 'b5bdd66678f0f2b205f2'

  # VSMS.club
  API_KEY = 'oT9Aj9GGbc27b7e4-4944-40dc-83d5-8c28ac5c179fgwUbiYff1423052435'

	DEFAULT_VALID_MOBILE_NUMBER = '03132100200'

	belongs_to :sender, polymorphic: true
	belongs_to :receiver, polymorphic: true

	before_validation :strip_to
	before_create :associate_receiver
	after_create :send_sms

	validates :message, presence: true

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
    http = Net::HTTP.new('vsms.club')
    request = Net::HTTP::Post.new('/api/Relay/SendSms')
    request.set_form_data(apikey: API_KEY, phonenumber: '92' + to[1..-1], message: message, senderid: 'criterion')
    response = http.request(request)

    decoded_response = ActiveSupport::JSON.decode(response.body)
    result = decoded_response['resultCode']
    api_response = decoded_response['resultMessage']

    update_attributes(status: (result == 0), api_response: api_response)
  end
end
