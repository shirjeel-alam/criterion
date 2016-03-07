# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  amount     :integer
#  share      :float
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Book < ActiveRecord::Base
  belongs_to :course
  has_many :payments, as: :item, dependent: :destroy

  validates :name, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :share, presence: true, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 1 }
  validates :course_id, presence: true

  before_validation :set_share
  after_save :create_payments

  ### View Helpers ###

  def title
    "#{name} - #{course.name}"
  end

  private

  def set_share
    self.share = course.teacher.share if share.blank?
  end

  def create_payments
    course.enrollments.map(&:save)
  end
end
