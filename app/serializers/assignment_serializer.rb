class AssignmentSerializer < Panko::Serializer
  attributes :id, :title, :instruction, :file_url, :due_date, :assignment_type, :classroom_id
end
