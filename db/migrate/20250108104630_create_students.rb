class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students, id: false do |t|
      t.primary_key :id
      t.string :phone, null: false, limit: 25
      t.string :address, limit: 50
      t.string :education_level, null: false
      t.string :medium
      t.integer :year
      t.string :degree_type
      t.string :degree_name, limit: 25
      t.string :semester_year, limit: 25

      t.timestamps
    end

    add_foreign_key :students, :users, column: :id, primary_key: :id
  end
end
