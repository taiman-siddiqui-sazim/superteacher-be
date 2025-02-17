class RemoveDefaultFromSubmissionIsLate < ActiveRecord::Migration[8.0]
  def change
    change_column_default :submissions, :is_late, from: false, to: nil
  end
end
