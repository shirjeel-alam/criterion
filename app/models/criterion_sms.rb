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
#  status        :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  api_response  :text
#

class CriterionSms < ActiveRecord::Base
  attr_accessor :extra

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

  def number
    '92' + to[1..-1]
  end

  def send_sms
    return if status || ENV['SEND_SMS'] == 'false'
    url = "http://sendpk.com/api/sms.php?username=#{ENV['SMS_USERNAME']}&password=#{ENV['SMS_PASSWORD']}&sender=Criterion&mobile=#{number}&message=#{message}"
    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    response = Net::HTTP.get(uri)
    result = response.split(' ').first == 'OK'
    update_attributes(status: result, api_response: response)
    status
  end

  ### Class Methods ###

  def self.send_cumulative_fee_received_sms(payment_ids)
    payments = Payment.find(payment_ids)
    cumulative_amount = payments.sum(&:net_amount)
    course_names = payments.collect(&:payable).collect(&:course).collect(&:title).join(', ')
    month_and_year = payments.first.period_label
    student = payments.first.payable.student
    student.phone_numbers.mobile.each do |phone_number|
      sms_data = { to: phone_number.number, message: "Dear Student, Your payment of Rs. #{cumulative_amount} against #{course_names} for the period #{month_and_year} has been received. Thank You" }
      student.received_messages.create(sms_data)
    end
  end

  ### Test Method ###

  def self.send_test_sms
    message = "Test SMS sent on #{Date.today.strftime("%d/%m/%Y")} at #{Time.now.strftime("%I:%M%p")}"

    bulk = false
    if !bulk
      number = '923222463936'
      url = "http://sendpk.com/api/sms.php?username=#{ENV['SMS_USERNAME']}&password=#{ENV['SMS_PASSWORD']}&sender=Criterion&mobile=#{number}&message=#{message}"
    else
      number = '923222463936,923129089081'
      url = "http://sendpk.com/api/bulksms.php?username=#{ENV['SMS_USERNAME']}&password=#{ENV['SMS_PASSWORD']}&sender=Criterion&mobile=#{number}&message=#{message}"
    end

    encoded_url = URI.encode(url)
    uri = URI.parse(encoded_url)
    response = Net::HTTP.get(uri)
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
end
