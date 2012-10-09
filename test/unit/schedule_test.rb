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

require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
