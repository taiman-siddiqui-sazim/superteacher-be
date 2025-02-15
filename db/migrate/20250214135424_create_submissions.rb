class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :submitted_at
      t.string :file_url
      t.boolean :is_late, default: false

      t.timestamps
    end
  end
end
