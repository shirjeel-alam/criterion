# == Schema Information
#
# Table name: criterion_mails
#
#  id            :integer(4)      not null, primary key
#  from          :string(255)
#  to            :string(255)
#  cc            :string(255)
#  bcc           :string(255)
#  subject       :string(255)
#  body          :text
#  mailable_id   :integer(4)
#  mailable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class CriterionMail < ActiveRecord::Base
	belongs_to :mailable, polymorphic: true

	validates :from, presence: true
	validates :to, presence: true
	validates :body, presence: true
end
