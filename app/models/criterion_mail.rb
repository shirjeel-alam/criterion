# == Schema Information
#
# Table name: criterion_mails
#
#  id            :integer          not null, primary key
#  from          :string(255)
#  to            :text
#  cc            :text
#  bcc           :text
#  subject       :string(255)
#  body          :text
#  mailable_id   :integer
#  mailable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CriterionMail < ActiveRecord::Base
	belongs_to :mailable, polymorphic: true

	validates :from, presence: true
	validates :to, presence: true
	validates :body, presence: true
end
