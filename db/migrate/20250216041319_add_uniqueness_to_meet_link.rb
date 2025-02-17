class AddUniquenessToMeetLink < ActiveRecord::Migration[8.0]
  def change
    add_index :meet_links, :meet_link, unique: true
  end
end
