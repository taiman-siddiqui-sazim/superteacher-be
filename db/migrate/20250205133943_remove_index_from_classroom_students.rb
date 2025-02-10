class RemoveIndexFromClassroomStudents < ActiveRecord::Migration[6.0]
  def change
    remove_index :classroom_students, name: "index_classroom_students_on_classroom_id_and_student_id"
  end
end
