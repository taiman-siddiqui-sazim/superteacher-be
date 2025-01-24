require "test_helper"

class TeacherTest < ActiveSupport::TestCase
  fixtures :users, :teachers

  setup do
    @teacher = teachers(:one)
  end

  test "should be valid with valid attributes" do
    assert @teacher.valid?
  end

  test "should be invalid without a major_subject" do
    @teacher.major_subject = nil
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:major_subject], "can't be blank"
  end

  test "should be invalid with a major_subject longer than 50 characters" do
    @teacher.major_subject = "a" * 51
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:major_subject], "is too long (maximum is 50 characters)"
  end

  test "should be invalid without subjects" do
    @teacher.subjects = []
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:subjects], "can't be blank"
  end

  test "should be invalid without highest_education" do
    @teacher.highest_education = nil
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:highest_education], "can't be blank"
  end

  test "should be invalid with an invalid highest_education" do
    @teacher.highest_education = "invalid_degree"
    assert_not @teacher.valid?
  end

  test "should be invalid if user is not a teacher" do
    @teacher.user.user_type = "student"
    assert_not @teacher.valid?
    assert_includes @teacher.errors[:user], "must exist and have a user_type of 'teacher'"
  end
end
