# spec/models/classwork/material_spec.rb
require 'rails_helper'

RSpec.describe Classwork::Material, type: :model do
  describe "associations" do
    it { should belong_to(:classroom).class_name("Classrooms::Classroom") }
  end

  describe "validations" do
    # Setup for required models
    let(:teacher_user) do
      Users::User.create!(
        first_name: "Teacher",
        last_name: "Smith",
        gender: "male",
        email: "teacher@example.com",
        user_type: "teacher",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:classroom) do
      # Mock the subject existence for classroom validation
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)

      Classrooms::Classroom.create!(
        title: "Mathematics 101",
        subject: "Mathematics",
        class_time: "9:00 - 10:00",
        days_of_week: [ "Monday", "Wednesday" ],
        teacher_id: teacher_user.id
      )
    end

    # Base attributes for a valid material
    let(:valid_attributes) do
      {
        title: "Math Concepts",
        instruction: "Read the following resources to understand basic math concepts...",
        classroom_id: classroom.id
      }
    end

    context "with valid attributes" do
      it "is valid with all required attributes" do
        material = described_class.new(valid_attributes)
        expect(material).to be_valid
      end
    end

    # Basic validations
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:instruction) }
    it { should validate_length_of(:instruction).is_at_most(5000) }
    it { should validate_presence_of(:classroom_id) }

    context "with invalid attributes" do
      it "is invalid without a title" do
        material = described_class.new(valid_attributes.merge(title: nil))
        expect(material).not_to be_valid
        expect(material.errors[:title]).to include("can't be blank")
      end

      it "is invalid with a title that's too long" do
        material = described_class.new(valid_attributes.merge(title: "a" * 256))
        expect(material).not_to be_valid
        expect(material.errors[:title]).to include("is too long (maximum is 255 characters)")
      end

      it "is invalid without instruction" do
        material = described_class.new(valid_attributes.merge(instruction: nil))
        expect(material).not_to be_valid
        expect(material.errors[:instruction]).to include("can't be blank")
      end

      it "is invalid with instruction that's too long" do
        material = described_class.new(valid_attributes.merge(instruction: "a" * 5001))
        expect(material).not_to be_valid
        expect(material.errors[:instruction]).to include("is too long (maximum is 5000 characters)")
      end

      it "is invalid without a classroom" do
        material = described_class.new(valid_attributes.merge(classroom_id: nil))
        expect(material).not_to be_valid
        expect(material.errors[:classroom_id]).to include("can't be blank")
      end
    end
  end

  describe "#classroom_users" do
    # Setup for required models
    let(:teacher_user) do
      Users::User.create!(
        first_name: "Teacher",
        last_name: "Smith",
        gender: "male",
        email: "teacher@example.com",
        user_type: "teacher",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:student_user) do
      Users::User.create!(
        first_name: "Student",
        last_name: "Jones",
        gender: "female",
        email: "student@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:student) do
      Users::Student.create!(
        user: student_user,
        phone: "1234567890",
        education_level: "school",
        medium: "english",
        year: 5
      )
    end

    let(:classroom) do
      # Mock the subject existence for classroom validation
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)

      Classrooms::Classroom.create!(
        title: "Mathematics 101",
        subject: "Mathematics",
        class_time: "9:00 - 10:00",
        days_of_week: [ "Monday", "Wednesday" ],
        teacher_id: teacher_user.id
      )
    end

    let(:material) do
      described_class.create!(
        title: "Math Concepts",
        instruction: "Read the following resources to understand basic math concepts...",
        classroom: classroom
      )
    end

    it "returns all users in the classroom" do
      # Enroll a student in the classroom
      Classrooms::ClassroomStudent.create!(
        classroom: classroom,
        student: student,
        enroll_date: Date.today
      )

      # Mock the classroom.users method since we already tested it in classroom_spec
      allow(classroom).to receive(:users).and_return([ teacher_user, student_user ])

      # Call the method and verify results
      users = material.classroom_users
      expect(users).to include(teacher_user)
      expect(users).to include(student_user)
      expect(users.count).to eq(2)
    end

    it "returns only the teacher when no students are enrolled" do
      # Mock the classroom.users method
      allow(classroom).to receive(:users).and_return([ teacher_user ])

      users = material.classroom_users
      expect(users).to include(teacher_user)
      expect(users.count).to eq(1)
    end
  end

  describe "real-world scenarios" do
    let(:teacher_user) do
      Users::User.create!(
        first_name: "Teacher",
        last_name: "Smith",
        gender: "male",
        email: "teacher@example.com",
        user_type: "teacher",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:classroom) do
      # Mock the subject existence for classroom validation
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)

      Classrooms::Classroom.create!(
        title: "Mathematics 101",
        subject: "Mathematics",
        class_time: "9:00 - 10:00",
        days_of_week: [ "Monday", "Wednesday" ],
        teacher_id: teacher_user.id
      )
    end

    it "allows creating a basic reading material" do
      material = described_class.new(
        title: "Introduction to Algebra",
        instruction: "Please read chapters 1-3 of the textbook for an introduction to algebra.",
        classroom: classroom
      )
      expect(material).to be_valid
    end

    it "allows creating material with file URLs" do
      material = described_class.new(
        title: "Geometry Resources",
        instruction: "Here are some helpful resources for understanding geometry concepts.",
        classroom: classroom,
        file_url: [ "https://example.com/geometry1.pdf", "https://example.com/geometry2.pdf" ]
      )
      expect(material).to be_valid
    end

    it "allows creating material with embedded content" do
      material = described_class.new(
        title: "Video Tutorial",
        instruction: "Watch this video to understand trigonometry better.",
        classroom: classroom,
        embedded_content: "<iframe src='https://www.youtube.com/embed/example' frameborder='0' allowfullscreen></iframe>"
      )
      expect(material).to be_valid
    end
  end
end
