# spec/models/users/student_spec.rb
require 'rails_helper'

RSpec.describe Users::Student, type: :model do
  describe "associations" do
    it { should belong_to(:user).class_name("Users::User") }
    it { should have_many(:classroom_students).dependent(:destroy) }
    it { should have_many(:classrooms).through(:classroom_students) }
  end

  describe "validations" do
    # Create a valid user for testing
    let(:user) do
      Users::User.create!(
        first_name: "Jane",
        last_name: "Doe",
        gender: "female",
        email: "jane.doe@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    # Base attributes for different education levels
    let(:base_attributes) do
      {
        user: user,
        phone: "1234567890",
        address: "123 Main St"
      }
    end

    let(:school_attributes) do
      base_attributes.merge(
        education_level: "school",
        medium: "english",
        year: 5
      )
    end

    let(:college_attributes) do
      base_attributes.merge(
        education_level: "college",
        medium: "english",
        year: 11
      )
    end

    let(:university_attributes) do
      base_attributes.merge(
        education_level: "university",
        degree_type: "bachelors",
        degree_name: "Computer Science",
        semester_year: "Year 2"
      )
    end

    context "with valid attributes" do
      it "is valid for school education level" do
        student = described_class.new(school_attributes)
        expect(student).to be_valid
      end

      it "is valid for college education level" do
        student = described_class.new(college_attributes)
        expect(student).to be_valid
      end

      it "is valid for university education level" do
        student = described_class.new(university_attributes)
        expect(student).to be_valid
      end
    end

    # Basic validations
    it { should validate_presence_of(:phone) }
    it { should validate_length_of(:phone).is_at_most(15) }
    it { should validate_length_of(:address).is_at_most(100) }
    it { should validate_presence_of(:education_level) }

    # Education level validation
    it "validates inclusion of education_level" do
      student = described_class.new(base_attributes.merge(education_level: "invalid"))
      expect(student).not_to be_valid
      expect(student.errors[:education_level]).to include("invalid is not a valid education level")
    end

    # School-specific validations
    context "when education_level is 'school'" do
      it "validates presence of medium" do
        student = described_class.new(school_attributes.merge(medium: nil))
        expect(student).not_to be_valid
        expect(student.errors[:medium]).to include("can't be blank")
      end

      it "validates inclusion of medium" do
        student = described_class.new(school_attributes.merge(medium: "invalid"))
        expect(student).not_to be_valid
        expect(student.errors[:medium]).to include("invalid is not a valid medium")
      end

      it "validates presence of year" do
        student = described_class.new(school_attributes.merge(year: nil))
        expect(student).not_to be_valid
        expect(student.errors[:year]).to include("can't be blank")
      end

      it "validates year is between 1 and 10" do
        student = described_class.new(school_attributes.merge(year: 11))
        expect(student).not_to be_valid
        expect(student.errors[:year]).to include("must be between 1 and 10")
      end

      it "doesn't allow degree fields" do
        student = described_class.new(
          school_attributes.merge(
            degree_type: "bachelors",
            degree_name: "Computer Science",
            semester_year: "Year 2"
          )
        )
        expect(student).not_to be_valid
        expect(student.errors[:degree_type]).to include("cannot be set if education level is not university")
        expect(student.errors[:degree_name]).to include("cannot be set if education level is not university")
        expect(student.errors[:semester_year]).to include("cannot be set if education level is not university")
      end
    end

    # College-specific validations
    context "when education_level is 'college'" do
      it "validates presence of medium" do
        student = described_class.new(college_attributes.merge(medium: nil))
        expect(student).not_to be_valid
        expect(student.errors[:medium]).to include("can't be blank")
      end

      it "validates inclusion of medium" do
        student = described_class.new(college_attributes.merge(medium: "invalid"))
        expect(student).not_to be_valid
        expect(student.errors[:medium]).to include("invalid is not a valid medium")
      end

      it "validates presence of year" do
        student = described_class.new(college_attributes.merge(year: nil))
        expect(student).not_to be_valid
        expect(student.errors[:year]).to include("can't be blank")
      end

      it "validates year is 11 or 12" do
        student = described_class.new(college_attributes.merge(year: 10))
        expect(student).not_to be_valid
        expect(student.errors[:year]).to include("must be 11 or 12")
      end

      it "doesn't allow degree fields" do
        student = described_class.new(
          college_attributes.merge(
            degree_type: "bachelors",
            degree_name: "Computer Science",
            semester_year: "Year 2"
          )
        )
        expect(student).not_to be_valid
        expect(student.errors[:degree_type]).to include("cannot be set if education level is not university")
        expect(student.errors[:degree_name]).to include("cannot be set if education level is not university")
        expect(student.errors[:semester_year]).to include("cannot be set if education level is not university")
      end
    end

    # University-specific validations
    context "when education_level is 'university'" do
      it "validates presence of degree_type" do
        student = described_class.new(university_attributes.merge(degree_type: nil))
        expect(student).not_to be_valid
        expect(student.errors[:degree_type]).to include("can't be blank")
      end

      it "validates inclusion of degree_type" do
        student = described_class.new(university_attributes.merge(degree_type: "invalid"))
        expect(student).not_to be_valid
        expect(student.errors[:degree_type]).to include("invalid is not a valid degree type")
      end

      it "validates presence of degree_name" do
        student = described_class.new(university_attributes.merge(degree_name: nil))
        expect(student).not_to be_valid
        expect(student.errors[:degree_name]).to include("can't be blank")
      end

      it "validates length of degree_name" do
        student = described_class.new(university_attributes.merge(degree_name: "a" * 51))
        expect(student).not_to be_valid
        expect(student.errors[:degree_name]).to include("is too long (maximum is 50 characters)")
      end

      it "validates presence of semester_year" do
        student = described_class.new(university_attributes.merge(semester_year: nil))
        expect(student).not_to be_valid
        expect(student.errors[:semester_year]).to include("can't be blank")
      end

      it "validates length of semester_year" do
        student = described_class.new(university_attributes.merge(semester_year: "a" * 26))
        expect(student).not_to be_valid
        expect(student.errors[:semester_year]).to include("is too long (maximum is 25 characters)")
      end

      it "doesn't allow school/college fields" do
        student = described_class.new(
          university_attributes.merge(
            medium: "english",
            year: 5
          )
        )
        expect(student).not_to be_valid
        expect(student.errors[:medium]).to include("cannot be set if education level is not school or college")
        expect(student.errors[:year]).to include("cannot be set if education level is not school or college")
      end
    end

    # User type validation
    context "user record validation" do
      it "validates user has student type" do
        teacher_user = Users::User.create!(
          first_name: "Teacher",
          last_name: "User",
          gender: "male",
          email: "teacher@example.com",
          user_type: "teacher",
          password: "Password1@",
          password_confirmation: "Password1@"
        )

        student = described_class.new(school_attributes.merge(user: teacher_user))
        expect(student).not_to be_valid
        expect(student.errors[:user]).to include("must exist and have a user_type of 'student'")
      end

      it "validates user exists" do
        student = described_class.new(school_attributes.merge(user: nil))
        expect(student).not_to be_valid
        expect(student.errors[:user]).to include("must exist")
        expect(student.errors[:user]).to include("must exist and have a user_type of 'student'")
      end
    end
  end
end
