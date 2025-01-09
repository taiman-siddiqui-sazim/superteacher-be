class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :phone, null: false, limit: 15
      t.string :address, limit: 100
      t.string :education_level, null: false
      t.string :medium
      t.integer :year
      t.string :degree_type
      t.string :degree_name, limit: 50
      t.string :semester_year, limit: 25
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
