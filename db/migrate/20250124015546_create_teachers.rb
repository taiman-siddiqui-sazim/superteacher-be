class CreateTeachers < ActiveRecord::Migration[8.0]
  def change
    create_table :teachers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :major_subject, null: false, limit: 50
      t.string :subjects, array: true, default: [], null: false
      t.string :highest_education, null: false

      t.timestamps
    end
  end
end
