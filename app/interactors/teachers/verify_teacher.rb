module Teachers
  class VerifyTeacher
    include Interactor

    UNIQUE_CODE_NOT_FOUND = "Unique code does not exist for user"
    INVALID_UNIQUE_CODE = "Invalid unique code. Attempts left: "
    NO_MORE_ATTEMPTS = "No more attempts left. Please obtain a new unique code."

    def call
      email = context.email
      unique_code = context.unique_code

      unique_code_record = UniqueCode.find_by(email: email)

      if unique_code_record.nil?
        context.fail!(message: UNIQUE_CODE_NOT_FOUND, status: :not_found)
      elsif unique_code_record.unique_code != unique_code
        handle_invalid_code(unique_code_record)
      else
        handle_valid_code(unique_code_record)
      end
    end

    private

    def handle_invalid_code(unique_code_record)
      if unique_code_record.attempts_left > 1
        unique_code_record.decrement!(:attempts_left)
        context.fail!(message: "#{INVALID_UNIQUE_CODE}#{unique_code_record.attempts_left}", status: :unprocessable_entity)
      else
        unique_code_record.destroy
        context.fail!(message: NO_MORE_ATTEMPTS, status: :unprocessable_entity)
      end
    end

    def handle_valid_code(unique_code_record)
      unique_code_record.update(attempts_left: 3)
      context.user_params = context.user_params.except(:unique_code, :controller, :action)
    end
  end
end
