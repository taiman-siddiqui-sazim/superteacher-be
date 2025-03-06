require 'rails_helper'

RSpec.describe Classrooms::ClassroomStudent, type: :model do
  describe "associations" do
    it { should belong_to(:classroom).class_name("Classrooms::Classroom") }
    it { should belong_to(:student).class_name("Users::Student") }
  end

  describe "validations" do
    it { should validate_presence_of(:enroll_date) }
  end

  describe "creating a classroom student record" do
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

    context "with valid attributes" do
      it "successfully creates a record" do
        classroom_student = described_class.new(
          classroom: classroom,
          student: student,
          enroll_date: Date.today
        )
        expect(classroom_student).to be_valid
        expect { classroom_student.save! }.not_to raise_error
      end
    end

    context "with invalid attributes" do
      it "fails without enroll_date" do
        classroom_student = described_class.new(
          classroom: classroom,
          student: student,
          enroll_date: nil
        )
        expect(classroom_student).not_to be_valid
        expect(classroom_student.errors[:enroll_date]).to include("can't be blank")
      end

      it "fails without a classroom" do
        classroom_student = described_class.new(
          classroom: nil,
          student: student,
          enroll_date: Date.today
        )
        expect(classroom_student).not_to be_valid
        expect(classroom_student.errors[:classroom]).to include("must exist")
      end

      it "fails without a student" do
        classroom_student = described_class.new(
          classroom: classroom,
          student: nil,
          enroll_date: Date.today
        )
        expect(classroom_student).not_to be_valid
        expect(classroom_student.errors[:student]).to include("must exist")
      end
    end
  end

  describe "real-world usage scenarios" do
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

    it "enrolls multiple students in a classroom" do
      # Create enrollments
      enrollment1 = described_class.create!(
        classroom: classroom,
        student: student1,
        enroll_date: Date.today
      )

      enrollment2 = described_class.create!(
        classroom: classroom,
        student: student2,
        enroll_date: Date.today - 1.day  # Enrolled yesterday
      )

      # Check that the classroom has these students
      expect(classroom.students).to include(student1)
      expect(classroom.students).to include(student2)
      expect(classroom.students.count).to eq(2)

      # Check that the students are enrolled in this classroom
      expect(student1.classrooms).to include(classroom)
      expect(student2.classrooms).to include(classroom)
    end

    it "allows enrolling a student with a past date" do
      past_date = Date.today - 30.days
      enrollment = described_class.create!(
        classroom: classroom,
        student: student1,
        enroll_date: past_date
      )

      expect(enrollment).to be_valid
      expect(enrollment.enroll_date).to eq(past_date)
    end

    it "allows enrolling a student with today's date" do
      today = Date.today
      enrollment = described_class.create!(
        classroom: classroom,
        student: student1,
        enroll_date: today
      )

      expect(enrollment).to be_valid
      expect(enrollment.enroll_date).to eq(today)
    end

    it "allows enrolling a student with a future date" do
      future_date = Date.today + 7.days
      enrollment = described_class.create!(
        classroom: classroom,
        student: student1,
        enroll_date: future_date
      )

      expect(enrollment).to be_valid
      expect(enrollment.enroll_date).to eq(future_date)
    end
  end
end
