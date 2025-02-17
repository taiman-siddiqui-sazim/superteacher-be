class RemoveMeetLinkFromClassrooms < ActiveRecord::Migration[8.0]
  def change
    remove_column :classrooms, :meet_link, :string
  end
end
