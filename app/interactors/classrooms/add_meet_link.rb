module Classrooms
    class AddMeetLink
      include Interactor
      include Constants::ClassroomConstants

      def call
        if Classrooms::MeetLink.exists?(classroom_id: context.classroom_id)
          context.fail!(
            message: MEET_LINK_EXISTS,
            status: :unprocessable_entity
          )
        end

        meet_link_record = Classrooms::MeetLink.new(
          classroom_id: context.classroom_id,
          meet_link: context.meet_link
        )

        unless meet_link_record.save
          context.fail!(
            message: meet_link_record.errors.full_messages.join(", "),
            status: :unprocessable_entity
          )
        end

        context.meet_link = meet_link_record
      end
    end
end
