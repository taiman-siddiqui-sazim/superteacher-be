require "sidekiq"
require "sidekiq/testing"

if Rails.env.development?
  # Run jobs immediately in development
  Sidekiq::Testing.inline!

  # Schedule the ExamReminderJob to run every minute
  Thread.new do
    while true
      begin
        Classrooms::ExamReminderJob.new.perform
        sleep 60
      rescue StandardError => e
        Rails.logger.error "ExamReminderJob error: #{e.message}"
        sleep 60
      end
    end
  rescue StandardError => e
    Rails.logger.error "Background thread error: #{e.message}"
    retry
  end
end
