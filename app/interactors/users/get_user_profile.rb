module Users
    class GetUserProfile
      include Interactor
      include Constants::UserConstants

      def call
        user = context.user

        unless user
          context.fail!(
            message: USER_NOT_FOUND,
            status: :not_found
          )
          return
        end

        context.profile_data = case user.user_type
        when "teacher"
          teacher = user.teacher
          unless teacher
            context.fail!(
              message: TEACHER_PROFILE_NOT_FOUND,
              status: :not_found
            )
            return
          end

          user_data = ::UserSerializer.new.serialize(user)
          user_data.merge(
            teacher_profile: teacher.as_json(
              except: [ :created_at, :updated_at ]
            )
          )
        when "student"
          student = user.student
          unless student
            context.fail!(
              message: STUDENT_PROFILE_NOT_FOUND,
              status: :not_found
            )
            return
          end

          user_data = ::UserSerializer.new.serialize(user)
          user_data.merge(
            student_profile: student.as_json(
              except: [ :created_at, :updated_at ]
            )
          )
        else
          ::UserSerializer.new.serialize(user)
        end
      end
    end
end
