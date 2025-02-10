class UpdateClassroomsToReferenceUsers < ActiveRecord::Migration[6.1]
  def change
    remove_reference :classrooms, :teacher, foreign_key: true
    add_reference :classrooms, :teacher, null: false, foreign_key: { to_table: :users }
  end
end
