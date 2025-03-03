module Classwork
    class SendClassworkEmail
      include Interactor

      def call
        if context.assignment.present?
          resource = context.assignment
          resource_type = "assignment"
        elsif context.material.present?
          resource = context.material
          resource_type = "material"
        else
          context.fail!(message: "No classwork resource provided")
          return
        end

        classroom_users = resource.classroom.users
        teacher_id = resource.classroom.teacher_id
        student_users = classroom_users.reject { |user| user.id == teacher_id }

        Rails.logger.info "Sending #{resource_type} creation emails to #{student_users.size} students"

        emails_sent = 0

        student_users.each do |user|
          begin
            UserMailer.classwork_email(user, resource).deliver_now
            emails_sent += 1
          rescue StandardError => e
            Rails.logger.error "Failed to send #{resource_type} email to #{user.email}: #{e.message}"
          end
        end

        context.emails_sent = emails_sent
        Rails.logger.info "Successfully sent #{emails_sent} #{resource_type} creation emails"
      rescue StandardError => e
        Rails.logger.error "Error in SendClassworkEmail: #{e.message}"
        context.fail!(message: "Failed to send classwork emails", error: e.message)
      end
    end
end
