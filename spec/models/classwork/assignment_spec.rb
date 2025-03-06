require 'rails_helper'

RSpec.describe Classwork::Assignment, type: :model do
  describe "associations" do
    it { should belong_to(:classroom).class_name("Classrooms::Classroom") }
    it { should have_many(:submissions).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
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

    # Base attributes for a valid assignment
    let(:valid_attributes) do
      future_date = (DateTime.now + 1.day).strftime("%d/%m/%Y %H:%M")
      {
        title: "Test Assignment",
        instruction: "Complete the following problems...",
        due_date: future_date,
        classroom_id: classroom.id,
        assignment_type: "assignment"
      }
    end

    context "with valid attributes" do
      it "is valid with all required attributes" do
        assignment = described_class.new(valid_attributes)
        expect(assignment).to be_valid
      end
    end

    # Basic validations
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:instruction) }
    it { should validate_length_of(:instruction).is_at_most(5000) }
    it { should validate_presence_of(:due_date) }
    it { should validate_presence_of(:classroom_id) }
    it { should validate_presence_of(:assignment_type) }

    context "assignment_type validation" do
      it "is valid with 'assignment'" do
        assignment = described_class.new(valid_attributes.merge(assignment_type: "assignment"))
        expect(assignment).to be_valid
      end

      it "is valid with 'exam'" do
        assignment = described_class.new(valid_attributes.merge(assignment_type: "exam"))
        expect(assignment).to be_valid
      end

      it "is invalid with other values" do
        assignment = described_class.new(valid_attributes.merge(assignment_type: "homework"))
        expect(assignment).not_to be_valid
        expect(assignment.errors[:assignment_type]).to include("is not included in the list")
      end
    end

    # Custom validation: validate_due_date_format
    context "due_date format validation" do
      it "is valid with correct format" do
        assignment = described_class.new(valid_attributes.merge(due_date: "25/12/2025 14:30"))
        expect(assignment).to be_valid
      end

      it "is invalid with incorrect format" do
        assignment = described_class.new(valid_attributes.merge(due_date: "2025-12-25 14:30"))
        expect(assignment).not_to be_valid
        expect(assignment.errors[:due_date]).to include("must be in format dd/mm/yyyy hh:mm")
      end

      it "is invalid with missing time" do
        assignment = described_class.new(valid_attributes.merge(due_date: "25/12/2025"))
        expect(assignment).not_to be_valid
        expect(assignment.errors[:due_date]).to include("must be in format dd/mm/yyyy hh:mm")
      end

      it "is invalid with missing date" do
        assignment = described_class.new(valid_attributes.merge(due_date: "14:30"))
        expect(assignment).not_to be_valid
        expect(assignment.errors[:due_date]).to include("must be in format dd/mm/yyyy hh:mm")
      end
    end

    # Custom validation: validate_due_date_future
    context "due_date future validation" do
      it "is valid with a future date" do
        future_date = (DateTime.now + 1.day).strftime("%d/%m/%Y %H:%M")
        assignment = described_class.new(valid_attributes.merge(due_date: future_date))
        expect(assignment).to be_valid
      end

      it "is invalid with a past date" do
        past_date = (DateTime.now - 1.day).strftime("%d/%m/%Y %H:%M")
        assignment = described_class.new(valid_attributes.merge(due_date: past_date))
        expect(assignment).not_to be_valid
        expect(assignment.errors[:due_date]).to include("must be in the future")
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
        password: "Password1@"
      )
    end

    let(:student_user) do
      Users::User.create!(
        first_name: "Student",
        last_name: "Jones",
        gender: "female",
        email: "student@example.com",
        user_type: "student",
        password: "Password1@"
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

    let(:assignment) do
      future_date = (DateTime.now + 1.day).strftime("%d/%m/%Y %H:%M")
      described_class.create!(
        title: "Test Assignment",
        instruction: "Complete the following problems...",
        due_date: future_date,
        classroom: classroom,
        assignment_type: "assignment"
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
      users = assignment.classroom_users
      expect(users).to include(teacher_user)
      expect(users).to include(student_user)
      expect(users.count).to eq(2)
    end

    it "returns only the teacher when no students are enrolled" do
      # Mock the classroom.users method
      allow(classroom).to receive(:users).and_return([ teacher_user ])

      users = assignment.classroom_users
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
        password: "Password1@"
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

    it "allows creating a regular assignment" do
      future_date = (DateTime.now + 1.week).strftime("%d/%m/%Y %H:%M")
      assignment = described_class.new(
        title: "Algebra Homework",
        instruction: "Complete exercises 1-10 on page 42 of the textbook.",
        due_date: future_date,
        classroom: classroom,
        assignment_type: "assignment"
      )
      expect(assignment).to be_valid
    end

    it "allows creating an exam" do
      future_date = (DateTime.now + 2.weeks).strftime("%d/%m/%Y %H:%M")
      assignment = described_class.new(
        title: "Midterm Exam",
        instruction: "This is a closed-book exam covering chapters 1-5.",
        due_date: future_date,
        classroom: classroom,
        assignment_type: "exam"
      )
      expect(assignment).to be_valid
    end

    it "allows creating an assignment with file attachments" do
      future_date = (DateTime.now + 1.week).strftime("%d/%m/%Y %H:%M")
      assignment = described_class.new(
        title: "Research Project",
        instruction: "Complete the research project as described in the attachment.",
        due_date: future_date,
        classroom: classroom,
        assignment_type: "assignment",
        file_url: [ "https://example.com/file1.pdf", "https://example.com/file2.docx" ]
      )
      expect(assignment).to be_valid
    end
  end
end
