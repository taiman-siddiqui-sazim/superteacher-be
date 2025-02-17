class CreateMeetLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :meet_links do |t|
      t.string :meet_link
      t.references :classroom, foreign_key: true, null: false
      t.timestamps
    end
  end
end
