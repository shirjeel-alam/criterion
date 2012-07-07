# == Schema Information
#
# Table name: session_students
#
#  id         :integer          not null, primary key
#  student_id :integer
#  session_id :integer
#  payment_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class SessionStudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
