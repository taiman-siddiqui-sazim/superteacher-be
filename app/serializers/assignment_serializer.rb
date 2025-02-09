module Classwork
    class AssignmentSerializer < ActiveModel::Serializer
      attributes :id, :title, :instruction, :file_url, :due_date, :classroom_id

      def due_date
        object.due_date&.iso8601
      end
    end
end
