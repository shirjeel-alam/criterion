# == Schema Information
#
# Table name: session_students
#
#  id         :integer(4)      not null, primary key
#  student_id :integer(4)
#  session_id :integer(4)
#  payment_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class SessionStudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
