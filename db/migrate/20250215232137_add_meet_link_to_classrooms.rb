class AddMeetLinkToClassrooms < ActiveRecord::Migration[8.0]
  def change
    add_column :classrooms, :meet_link, :string
  end
end
