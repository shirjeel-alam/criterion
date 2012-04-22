# == Schema Information
#
# Table name: partners
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  email      :string(255)
#  share      :float
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PartnerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
