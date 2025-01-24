namespace :unique_code do
    desc "Generate a unique code and create a record in the unique_codes table"
    task create: :environment do
      def generate_unique_code
        loop do
          code = rand.to_s[2..7]
          return code unless UniqueCode.exists?(unique_code: code)
        end
      end

      def create_unique_code_record(email)
        if UniqueCode.exists?(email: email)
          puts "Email already exists in the unique_codes table."
        else
          unique_code = generate_unique_code
          attempts_left = 3

          unique_code_record = UniqueCode.new(email: email, unique_code: unique_code, attempts_left: attempts_left)

          if unique_code_record.save
            puts "Unique code record created successfully:"
            puts "Email: #{email}"
            puts "Unique Code: #{unique_code}"
            puts "Attempts Left: #{attempts_left}"
          else
            puts "Failed to create unique code record:"
            puts unique_code_record.errors.full_messages
          end
        end
      end

      # Example usage:
      email = ENV["EMAIL"]
      if email.present?
        create_unique_code_record(email)
      else
        puts "Please provide an email address using the EMAIL environment variable."
      end
    end
  end
