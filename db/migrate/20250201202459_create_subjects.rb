class CreateSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :subjects do |t|
      t.string :subject, null: false, unique: true

      t.timestamps
    end
  end
end
