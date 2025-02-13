class AddAssignmentTypeToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :assignments, :assignment_type, :string, null: false, default: 'assignment'
    add_check_constraint :assignments, "assignment_type IN ('exam', 'assignment')", name: 'valid_assignment_type'
  end
end
