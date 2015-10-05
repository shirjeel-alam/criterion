# == Schema Information
#
# Table name: schedules
#
#  id         :integer          not null, primary key
#  start      :time
#  end        :time
#  day        :string(255)
#  room       :integer
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Schedule < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :start, :end, :day, :room, :course_id

  ### View Helpers ###

  def title
    "Schedule: #{course.name}"
  end

  def label
    "#{day}, #{start.strftime('%l:%M %p')} - #{self.end.strftime('%l:%M %p')} in Room #{room}"
  end
end