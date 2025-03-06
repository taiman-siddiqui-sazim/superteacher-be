# spec/models/users/teacher_spec.rb
require 'rails_helper'

RSpec.describe Users::Teacher, type: :model do
  describe "associations" do
    it { should belong_to(:user).class_name("Users::User") }
  end

  describe "validations" do
    # Create a valid user for testing
    let(:user) do
      Users::User.create!(
        first_name: "John",
        last_name: "Smith",
        gender: "male",
        email: "john.smith@example.com",
        user_type: "teacher",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    # Base attributes for a valid teacher
    let(:valid_attributes) do
      {
        user: user,
        major_subject: "Mathematics",
        subjects: [ "Mathematics", "Physics" ],
        highest_education: "masters"
      }
    end

    context "with valid attributes" do
      it "is valid with all required attributes" do
        teacher = described_class.new(valid_attributes)
        expect(teacher).to be_valid
      end
    end

    # Basic validations
    it { should validate_presence_of(:major_subject) }
    it { should validate_length_of(:major_subject).is_at_most(50) }
    it { should validate_presence_of(:subjects) }
    it { should validate_presence_of(:highest_education) }

    # Major subject validations
    context "major_subject validation" do
      it "is invalid with a major_subject that's too long" do
        teacher = described_class.new(valid_attributes.merge(major_subject: "a" * 51))
        expect(teacher).not_to be_valid
        expect(teacher.errors[:major_subject]).to include("is too long (maximum is 50 characters)")
      end
    end

    # Subjects validations
    context "subjects validation" do
      it "is invalid with empty subjects array" do
        teacher = described_class.new(valid_attributes.merge(subjects: []))
        expect(teacher).not_to be_valid
        expect(teacher.errors[:subjects]).to include("is too short (minimum is 1 character)")
      end

      it "is valid with one subject" do
        teacher = described_class.new(valid_attributes.merge(subjects: [ "Physics" ]))
        expect(teacher).to be_valid
      end

      it "is valid with multiple subjects" do
        teacher = described_class.new(
          valid_attributes.merge(subjects: [ "Mathematics", "Physics", "Chemistry" ])
        )
        expect(teacher).to be_valid
      end
    end

    # Highest education validations
    context "highest_education validation" do
      it "is valid with bachelors" do
        teacher = described_class.new(valid_attributes.merge(highest_education: "bachelors"))
        expect(teacher).to be_valid
      end

      it "is valid with masters" do
        teacher = described_class.new(valid_attributes.merge(highest_education: "masters"))
        expect(teacher).to be_valid
      end

      it "is valid with phd" do
        teacher = described_class.new(valid_attributes.merge(highest_education: "phd"))
        expect(teacher).to be_valid
      end

      it "is invalid with other values" do
        teacher = described_class.new(valid_attributes.merge(highest_education: "diploma"))
        expect(teacher).not_to be_valid
        expect(teacher.errors[:highest_education]).to include("diploma is not a valid highest education")
      end
    end

    # User type validation
    context "user record validation" do
      it "validates user has teacher type" do
        student_user = Users::User.create!(
          first_name: "Student",
          last_name: "User",
          gender: "female",
          email: "student@example.com",
          user_type: "student",
          password: "Password1@",
          password_confirmation: "Password1@"
        )

        teacher = described_class.new(valid_attributes.merge(user: student_user))
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user]).to include("must exist and have a user_type of 'teacher'")
      end

      it "validates user exists" do
        teacher = described_class.new(valid_attributes.merge(user: nil))
        expect(teacher).not_to be_valid
        expect(teacher.errors[:user]).to include("must exist")
        expect(teacher.errors[:user]).to include("must exist and have a user_type of 'teacher'")
      end
    end
  end

  describe "real-world scenarios" do
    let(:user) do
      Users::User.create!(
        first_name: "John",
        last_name: "Smith",
        gender: "male",
        email: "john.smith@example.com",
        user_type: "teacher",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    it "allows creating a science teacher" do
      teacher = described_class.new(
        user: user,
        major_subject: "Physics",
        subjects: [ "Physics", "Chemistry", "Biology" ],
        highest_education: "phd"
      )
      expect(teacher).to be_valid
    end

    it "allows creating a language teacher" do
      teacher = described_class.new(
        user: user,
        major_subject: "English Literature",
        subjects: [ "English" ],
        highest_education: "masters"
      )
      expect(teacher).to be_valid
    end

    it "allows creating a primary school teacher with many subjects" do
      teacher = described_class.new(
        user: user,
        major_subject: "Elementary Education",
        subjects: [ "Mathematics", "English" ],
        highest_education: "bachelors"
      )
      expect(teacher).to be_valid
    end
  end
end
