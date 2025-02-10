class CreateClassrooms < ActiveRecord::Migration[6.1]
  def change
    create_table :classrooms do |t|
      t.string :title
      t.string :subject
      t.string :class_time
      t.string :days_of_week, array: true, default: []
      t.references :teacher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
