user = User.create!(
  first_name: "John",
  last_name: "Doe",
  gender: "male",
  email: "john.doe@example.com",
  password: "Password1!",
  user_type: "student"
)

Student.create!(
  phone: "1234567890",
  address: "123 Main St",
  education_level: "school",
  medium: "english",
  year: 10,
  user: user
)
