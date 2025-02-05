class CreateClassroomStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :classroom_students do |t|
      t.references :classroom, null: false, foreign_key: { to_table: :classrooms }
      t.references :student, null: false, foreign_key: { to_table: :students }
      t.date :enroll_date, null: false

      t.timestamps
    end

    add_index :classroom_students, [ :classroom_id, :student_id ], unique: true
  end
end
