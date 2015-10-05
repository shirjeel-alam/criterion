# == Schema Information
#
# Table name: action_requests
#
#  id                :integer          not null, primary key
#  action            :string(255)
#  requested_by_id   :integer
#  facilitated_by_id :integer
#  action_item_id    :integer
#  action_item_type  :string(255)
#  state             :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ActionRequest < ActiveRecord::Base
  include AASM

  belongs_to :action_item, polymorphic: true
  belongs_to :requested_by, class_name: 'AdminUser'
  belongs_to :facilitated_by, class_name: 'AdminUser'

  validates :action, presence: true

  scope :cancel, where(action: 'cancel')
  scope :void, where(action: 'void')

  aasm column: :state do
    state :pending, initial: true
    state :approved
    state :rejected

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  def approve_request!(admin_user)
    perform_action!
    self.approve!
    self.update_attribute(:facilitated_by_id, admin_user.id)
  end

  def reject_request!(admin_user)
    self.reject!
    self.update_attribute(:facilitated_by_id, admin_user.id)
  end

  def perform_action!
    action_item.send "#{action}!"
  end

  ### View Helpers ###

  def state_label
    state
  end
  
  def state_tag
    case state
      when 'pending'
        :warning
      when 'approved'
        :ok
      when 'rejected'
        :error
    end
  end
end