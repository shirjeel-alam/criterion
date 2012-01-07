require 'test_helper'

class CriterionMailerTest < ActionMailer::TestCase
  test "course_mail" do
    mail = CriterionMailer.course_mail
    assert_equal "Course mail", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
