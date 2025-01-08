class Student < ApplicationRecord
<<<<<<< HEAD
  belongs_to :user

  validates :phone, presence: true, length: { maximum: 15 }
  validates :address, length: { maximum: 100 }
  validates :education_level, presence: true, inclusion: { in: %w[school college university], message: "%{value} is not a valid education level" }
  validates :medium, presence: true, inclusion: { in: %w[english bangla], message: "%{value} is not a valid medium" }, if: -> { education_level == "school" || education_level == "college" }
  validates :year, presence: true, inclusion: { in: 1..10, message: "must be between 1 and 10" }, if: -> { education_level == "school" }
  validates :year, presence: true, inclusion: { in: 11..12, message: "must be 11 or 12" }, if: -> { education_level == "college" }
  validates :degree_type, presence: true, inclusion: { in: %w[bachelors masters], message: "%{value} is not a valid degree type" }, if: -> { education_level == "university" }
  validates :degree_name, presence: true, length: { maximum: 50 }, if: -> { education_level == "university" }
  validates :semester_year, presence: true, length: { maximum: 25 }, if: -> { education_level == "university" }

  validate :degree_fields_not_set_if_not_university
  validate :school_or_college_fields_not_set_if_not_school_or_college
  validate :user_record_must_be_student
=======
  self.primary_key = :id

  belongs_to :user, foreign_key: :id

  validates :phone, presence: true, length: { maximum: 25 }
  validates :address, length: { maximum: 50 }
  validates :education_level, presence: true, inclusion: { in: %w(school university), message: "%{value} is not a valid education level" }
  validates :medium, presence: true, inclusion: { in: %w(english bangla), message: "%{value} is not a valid medium" }, if: -> { education_level == 'school' }
  validates :year, presence: true, inclusion: { in: 5..12, message: "must be between 5 and 12" }, if: -> { education_level == 'school' }
  validates :degree_type, presence: true, inclusion: { in: %w(bachelors masters), message: "%{value} is not a valid degree type" }, if: -> { education_level == 'university' }
  validates :degree_name, presence: true, length: { maximum: 25 }, if: -> { education_level == 'university' }
  validates :semester_year, presence: true, length: { maximum: 25 }, if: -> { education_level == 'university' }

  validate :degree_fields_not_set_if_not_university
  validate :school_fields_not_set_if_not_school
  validate :user_record_exists_with_student_user_type
>>>>>>> 87ac406 (feat(st-3): create user and student models with validations and tests)

  private

  def degree_fields_not_set_if_not_university
<<<<<<< HEAD
    if education_level != "university"
=======
    if education_level != 'university'
>>>>>>> 87ac406 (feat(st-3): create user and student models with validations and tests)
      errors.add(:degree_type, "cannot be set if education level is not university") if degree_type.present?
      errors.add(:degree_name, "cannot be set if education level is not university") if degree_name.present?
      errors.add(:semester_year, "cannot be set if education level is not university") if semester_year.present?
    end
  end

<<<<<<< HEAD
  def school_or_college_fields_not_set_if_not_school_or_college
    if education_level != "school" && education_level != "college"
      errors.add(:medium, "cannot be set if education level is not school or college") if medium.present?
      errors.add(:year, "cannot be set if education level is not school or college") if year.present?
    end
  end

  def user_record_must_be_student
    if user && user.user_type != "student"
      errors.add(:user, "must have a user_type of 'student'")
=======
  def school_fields_not_set_if_not_school
    if education_level != 'school'
      errors.add(:medium, "cannot be set if education level is not school") if medium.present?
      errors.add(:year, "cannot be set if education level is not school") if year.present?
    end
  end

  def user_record_exists_with_student_user_type
    unless User.exists?(id: id, user_type: 'student')
      errors.add(:base, "User record with user_type 'student' must exist for this student")
>>>>>>> 87ac406 (feat(st-3): create user and student models with validations and tests)
    end
  end
end
