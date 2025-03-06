# spec/models/users/user_spec.rb
require 'rails_helper'

RSpec.describe Users::User, type: :model do
  describe "associations" do
    it { should have_one(:student).dependent(:destroy) }
    it { should have_one(:teacher).dependent(:destroy) }
    it { should have_many(:classrooms).dependent(:destroy) }
    it { should have_many(:submissions).dependent(:destroy) }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe "validations" do
    # Create a valid user for testing
    let(:valid_attributes) do
      {
        first_name: "John",
        last_name: "Doe",
        gender: "male",
        email: "john.doe@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      }
    end

    it "is valid with valid attributes" do
      user = described_class.new(valid_attributes)
      expect(user).to be_valid
    end

    # Presence validations
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:gender) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:user_type) }

    # Length validations
    it { should validate_length_of(:first_name).is_at_most(50).with_message("must be at most 50 characters long") }
    it { should validate_length_of(:last_name).is_at_most(50).with_message("must be at most 50 characters long") }
    it { should validate_length_of(:password).is_at_least(8).is_at_most(128).with_message("must be between 8 and 128 characters long") }

    # Inclusion validations - test manually instead of using shoulda matchers
    it "validates inclusion of user_type in allowed values" do
      user = described_class.new(valid_attributes.merge(user_type: "admin"))
      expect(user).not_to be_valid
      expect(user.errors[:user_type]).to include("admin is not a valid user type")
    end

    it "validates inclusion of gender in allowed values" do
      user = described_class.new(valid_attributes.merge(gender: "invalid"))
      expect(user).not_to be_valid
      expect(user.errors[:gender]).to include("invalid is not a valid gender")
    end

    # Email validations
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid-email").for(:email) }

    it "validates uniqueness of email" do
      described_class.create!(valid_attributes)
      duplicate_user = described_class.new(valid_attributes)
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end

    # Password validations
    context "password complexity" do
      it "requires a lowercase letter" do
        user = described_class.new(valid_attributes.merge(password: "PASSWORD1@", password_confirmation: "PASSWORD1@"))
        expect(user).not_to be_valid
        # Use regex to match the error message regardless of newlines
        expect(user.errors[:password].first).to match(/must include at least one lowercase letter, one uppercase letter, one digit.*and one special character/m)
      end

      it "requires an uppercase letter" do
        user = described_class.new(valid_attributes.merge(password: "password1@", password_confirmation: "password1@"))
        expect(user).not_to be_valid
        expect(user.errors[:password].first).to match(/must include at least one lowercase letter, one uppercase letter, one digit.*and one special character/m)
      end

      it "requires a digit" do
        user = described_class.new(valid_attributes.merge(password: "Password@", password_confirmation: "Password@"))
        expect(user).not_to be_valid
        expect(user.errors[:password].first).to match(/must include at least one lowercase letter, one uppercase letter, one digit.*and one special character/m)
      end

      it "requires a special character" do
        user = described_class.new(valid_attributes.merge(password: "Password1", password_confirmation: "Password1"))
        expect(user).not_to be_valid
        expect(user.errors[:password].first).to match(/must include at least one lowercase letter, one uppercase letter, one digit.*and one special character/m)
      end
    end

    # OTP validation
    context "OTP format" do
      it { should allow_value("123456").for(:otp) }
      it { should_not allow_value("12345").for(:otp) }
      it { should_not allow_value("1234567").for(:otp) }
      it { should_not allow_value("abcdef").for(:otp) }
    end
  end

  describe "#otp_expired?" do
    let(:user) { described_class.new(otp_sent_at: Time.current) }

    it "returns false when OTP is not expired" do
      expect(user.otp_expired?).to be false
    end

    it "returns true when OTP is expired" do
      user.otp_sent_at = 6.minutes.ago
      expect(user.otp_expired?).to be true
    end
  end

  describe "secure password" do
    it "hashes the password" do
      user = Users::User.create!(
        first_name: "John",
        last_name: "Doe",
        gender: "male",
        email: "secure@example.com",
        user_type: "student",
        password: "Password1@",
        password_confirmation: "Password1@"
      )

      expect(user.password_digest).to be_present
      expect(user.authenticate("Password1@")).to eq(user)
      expect(user.authenticate("WrongPassword")).to be false
    end
  end
end
