require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @student_one = students(:one)
    @student_two = students(:two)
  end

  test "should be valid with valid attributes for student one" do
    assert @student_one.valid?
  end

  test "should be valid with valid attributes for student two" do
    assert @student_two.valid?
  end

  test "should be invalid without a phone for student one" do
    @student_one.phone = nil
    assert_not @student_one.valid?
  end

  test "should be invalid with a phone longer than 15 characters for student one" do
    @student_one.phone = "a" * 16
    assert_not @student_one.valid?
  end

  test "should be invalid with an address longer than 100 characters for student one" do
    @student_one.address = "a" * 101
    assert_not @student_one.valid?
  end

  test "should be invalid without an education_level for student one" do
    @student_one.education_level = nil
    assert_not @student_one.valid?
  end

  test "should be invalid with an invalid education_level for student one" do
    @student_one.education_level = "invalid_level"
    assert_not @student_one.valid?
  end

  test "should be invalid without a medium if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.medium = nil
    assert_not @student_one.valid?
  end

  test "should be invalid with an invalid medium if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.medium = "invalid_medium"
    assert_not @student_one.valid?
  end

  test "should be invalid without a year if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.year = nil
    assert_not @student_one.valid?
  end

  test "should be invalid with an invalid year if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.year = 0
    assert_not @student_one.valid?
    @student_one.year = 11
    assert_not @student_one.valid?
  end

  test "should be invalid without a year if education_level is college for student one" do
    @student_one.education_level = "college"
    @student_one.year = nil
    assert_not @student_one.valid?
  end

  test "should be invalid with an invalid year if education_level is college for student one" do
    @student_one.education_level = "college"
    @student_one.year = 10
    assert_not @student_one.valid?
    @student_one.year = 13
    assert_not @student_one.valid?
  end

  test "should be invalid without a degree_type if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.degree_type = nil
    assert_not @student_two.valid?
  end

  test "should be invalid with a degree_type if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.degree_type = "bachelors"
    assert_not @student_one.valid?
  end

  test "should be invalid with a degree_name if education_level is school for student one" do
    @student_one.education_level = "school"
    @student_one.degree_name = "Computer Science"
    assert_not @student_one.valid?
  end

  test "should be invalid with a degree_type if education_level is college for student one" do
    @student_one.education_level = "college"
    @student_one.degree_type = "bachelors"
    assert_not @student_one.valid?
  end

  test "should be invalid with a degree_name if education_level is college for student one" do
    @student_one.education_level = "college"
    @student_one.degree_name = "Computer Science"
    assert_not @student_one.valid?
  end

  test "should be invalid with a medium if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.medium = "english"
    assert_not @student_two.valid?
  end

  test "should be invalid with a year if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.year = 10
    assert_not @student_two.valid?
  end

  test "should be invalid with an invalid degree_type if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.degree_type = "invalid_degree"
    assert_not @student_two.valid?
  end

  test "should be invalid without a degree_name if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.degree_name = nil
    assert_not @student_two.valid?
  end

  test "should be invalid with a degree_name longer than 50 characters if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.degree_name = "a" * 51
    assert_not @student_two.valid?
  end

  test "should be invalid without a semester_year if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.semester_year = nil
    assert_not @student_two.valid?
  end

  test "should be invalid with a semester_year longer than 25 characters if education_level is university for student two" do
    @student_two.education_level = "university"
    @student_two.semester_year = "a" * 26
    assert_not @student_two.valid?
  end

  test "should be invalid without a corresponding user record with user_type 'student'" do
    @student_one.user = nil
    assert_not @student_one.valid?
  end

  test "should be invalid if corresponding user record does not have user_type 'student'" do
    user = users(:one)
    user.update(user_type: "teacher")
    @student_one.user = user
    assert_not @student_one.valid?
  end
end
