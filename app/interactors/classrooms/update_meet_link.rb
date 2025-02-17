module Classrooms
    class UpdateMeetLink
      include Interactor
      include Constants::ClassroomConstants

      def call
        meet_link_record = Classrooms::MeetLink.find_by(classroom_id: context.classroom_id)

        unless meet_link_record
          context.fail!(
            message: MEET_LINK_NOT_FOUND,
            status: :not_found
          )
        end

        unless meet_link_record.update(meet_link: context.meet_link)
          context.fail!(
            message: meet_link_record.errors.full_messages.join(", "),
            status: :unprocessable_entity
          )
        end

        context.meet_link = meet_link_record
      end
    end
end
