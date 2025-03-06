require 'rails_helper'

RSpec.describe Classrooms::Classroom, type: :model do
  describe "associations" do
    it { should belong_to(:user).with_foreign_key(:teacher_id) }
    it { should have_many(:classroom_students).dependent(:destroy) }
    it { should have_many(:students).through(:classroom_students) }
    it { should have_many(:assignments).dependent(:destroy) }
    it { should have_one(:meet_link).dependent(:destroy) }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe "validations" do
    # Create necessary records for testing
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

    let(:teacher) do
      Users::Teacher.create!(
        user: teacher_user,
        major_subject: "Mathematics",
        subjects: [ "Mathematics" ],
        highest_education: "masters"
      )
    end

    # Mock the subject existence
    before do
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)
    end

    # Base attributes for a valid classroom
    let(:valid_attributes) do
      {
        title: "Mathematics 101",
        subject: "Mathematics",
        class_time: "9:00 - 10:00",
        days_of_week: [ "Monday", "Wednesday" ],
        teacher_id: teacher_user.id
      }
    end

    context "with valid attributes" do
      it "is valid with all required attributes" do
        classroom = described_class.new(valid_attributes)
        expect(classroom).to be_valid
      end
    end

    # Basic validations
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:class_time) }
    it "validates presence of days_of_week" do
        classroom = described_class.new(valid_attributes.merge(days_of_week: nil))
        expect(classroom).not_to be_valid
        expect(classroom.errors[:days_of_week]).to include("can't be blank")
      end

    it { should validate_length_of(:title).is_at_least(1).is_at_most(100) }
    it { should validate_length_of(:class_time).is_at_least(5).is_at_most(15) }

    # Custom validation: valid_days_of_week
    context "days_of_week validation" do
      it "is valid with all valid days" do
        classroom = described_class.new(valid_attributes)
        expect(classroom).to be_valid
      end

      it "is valid with lowercase days" do
        classroom = described_class.new(
          valid_attributes.merge(days_of_week: [ "monday", "wednesday" ])
        )
        expect(classroom).to be_valid
      end

      it "is valid with mixed case days" do
        classroom = described_class.new(
          valid_attributes.merge(days_of_week: [ "Monday", "wednesday" ])
        )
        expect(classroom).to be_valid
      end

      it "is invalid with invalid days" do
        classroom = described_class.new(
          valid_attributes.merge(days_of_week: [ "Monday", "InvalidDay" ])
        )
        expect(classroom).not_to be_valid
        expect(classroom.errors[:days_of_week]).to include("must contain valid days of the week")
      end

      it "is invalid with empty array" do
        classroom = described_class.new(
          valid_attributes.merge(days_of_week: [])
        )
        expect(classroom).not_to be_valid
      end

      it "is invalid with too many days" do
        classroom = described_class.new(
          valid_attributes.merge(days_of_week: [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" ])
        )
        expect(classroom).not_to be_valid
        expect(classroom.errors[:days_of_week]).to include("is too long (maximum is 4 characters)")
      end
    end

    # Custom validation: subject_exists
    context "subject validation" do
      it "is valid when subject exists" do
        allow(Classrooms::Subject).to receive(:exists?).with(subject: "Mathematics").and_return(true)
        classroom = described_class.new(valid_attributes)
        expect(classroom).to be_valid
      end

      it "is invalid when subject doesn't exist" do
        allow(Classrooms::Subject).to receive(:exists?).with(subject: "NonExistentSubject").and_return(false)
        classroom = described_class.new(
          valid_attributes.merge(subject: "NonExistentSubject")
        )
        expect(classroom).not_to be_valid
        expect(classroom.errors[:subject]).to include("must be a valid subject")
      end
    end

    # Custom validation: valid_teacher
    context "teacher validation" do
      it "is valid when teacher exists and is a teacher" do
        classroom = described_class.new(valid_attributes)
        expect(classroom).to be_valid
      end

      it "is invalid when teacher doesn't exist" do
        classroom = described_class.new(
          valid_attributes.merge(teacher_id: -1)  # Non-existent ID
        )
        expect(classroom).not_to be_valid
        expect(classroom.errors[:teacher_id]).to include("must be a valid teacher")
      end

      it "is invalid when user exists but is not a teacher" do
        student_user = Users::User.create!(
          first_name: "Student",
          last_name: "Jones",
          gender: "female",
          email: "student@example.com",
          user_type: "student",
          password: "Password1@",
          password_confirmation: "Password1@"
        )

        classroom = described_class.new(
          valid_attributes.merge(teacher_id: student_user.id)
        )
        expect(classroom).not_to be_valid
        expect(classroom.errors[:teacher_id]).to include("must be a valid teacher")
      end
    end

    # Uniqueness validation
    context "uniqueness validation" do
      it "validates uniqueness of teacher_id scoped to title, subject, class_time, and days_of_week" do
        # Create a classroom with the valid attributes
        described_class.create!(valid_attributes)

        # Try to create a duplicate classroom
        duplicate = described_class.new(valid_attributes)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:teacher_id]).to include("duplicate record exists")
      end

      it "allows creating classroom with same teacher but different title" do
        described_class.create!(valid_attributes)

        new_classroom = described_class.new(
          valid_attributes.merge(title: "Different Mathematics Class")
        )
        expect(new_classroom).to be_valid
      end

      it "allows creating classroom with same teacher but different subject" do
        described_class.create!(valid_attributes)

        allow(Classrooms::Subject).to receive(:exists?).with(subject: "Physics").and_return(true)
        new_classroom = described_class.new(
          valid_attributes.merge(subject: "Physics")
        )
        expect(new_classroom).to be_valid
      end

      it "allows creating classroom with same teacher but different class time" do
        described_class.create!(valid_attributes)

        new_classroom = described_class.new(
          valid_attributes.merge(class_time: "14:00 - 15:00")
        )
        expect(new_classroom).to be_valid
      end

      it "allows creating classroom with same teacher but different days" do
        described_class.create!(valid_attributes)

        new_classroom = described_class.new(
          valid_attributes.merge(days_of_week: [ "Tuesday", "Thursday" ])
        )
        expect(new_classroom).to be_valid
      end
    end
  end

  describe "#users" do
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

    let(:student_user1) do
      Users::User.create!(
        first_name: "Student1",
        last_name: "Jones",
        gender: "female",
        email: "student1@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:student_user2) do
      Users::User.create!(
        first_name: "Student2",
        last_name: "Brown",
        gender: "male",
        email: "student2@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      )
    end

    let(:student1) do
      Users::Student.create!(
        user: student_user1,
        phone: "1234567890",
        education_level: "school",
        medium: "english",
        year: 5
      )
    end

    let(:student2) do
      Users::Student.create!(
        user: student_user2,
        phone: "0987654321",
        education_level: "school",
        medium: "english",
        year: 6
      )
    end

    let(:classroom) do
      # Mock the subject existence
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)

      described_class.create!(
        title: "Mathematics 101",
        subject: "Mathematics",
        class_time: "9:00 - 10:00",
        days_of_week: [ "Monday", "Wednesday" ],
        teacher_id: teacher_user.id
      )
    end

    it "returns all users associated with the classroom" do
      # Create classroom_student relationships
      Classrooms::ClassroomStudent.create!(
        classroom: classroom,
        student: student1,
        enroll_date: Date.today
      )
      Classrooms::ClassroomStudent.create!(
        classroom: classroom,
        student: student2,
        enroll_date: Date.today
      )

      # Check that users method returns all users
      users = classroom.users
      expect(users).to include(teacher_user)
      expect(users).to include(student_user1)
      expect(users).to include(student_user2)
      expect(users.count).to eq(3)
    end

    it "returns only the teacher when no students are enrolled" do
      users = classroom.users
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

    before do
      allow(Classrooms::Subject).to receive(:exists?).and_return(true)
    end

    it "allows creating a morning class" do
      classroom = described_class.new(
        title: "Morning Mathematics",
        subject: "Mathematics",
        class_time: "08:00 - 09:30",
        days_of_week: [ "Monday", "Wednesday", "Friday" ],
        teacher_id: teacher_user.id
      )
      expect(classroom).to be_valid
    end

    it "allows creating an evening class" do
      classroom = described_class.new(
        title: "Evening Science",
        subject: "Physics",
        class_time: "18:00 - 19:30",
        days_of_week: [ "Tuesday", "Thursday" ],
        teacher_id: teacher_user.id
      )
      expect(classroom).to be_valid
    end

    it "allows creating a weekend class" do
      classroom = described_class.new(
        title: "Weekend Art",
        subject: "Art",
        class_time: "10:00 - 12:00",
        days_of_week: [ "Saturday", "Sunday" ],
        teacher_id: teacher_user.id
      )
      expect(classroom).to be_valid
    end
  end
end
