class ChangeDueDateToStringInAssignments < ActiveRecord::Migration[8.0]
  def change
    change_column :assignments, :due_date, :string
  end
end
