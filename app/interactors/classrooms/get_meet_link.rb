module Classrooms
    class GetMeetLink
      include Interactor
      include Constants::ClassroomConstants

      def call
        meet_link = Classrooms::MeetLink.find_by(classroom_id: context.classroom_id)

        unless meet_link
          context.fail!(
            message: MEET_LINK_NOT_FOUND,
            status: :not_found
          )
        end

        context.meet_link = meet_link
      end
    end
end
