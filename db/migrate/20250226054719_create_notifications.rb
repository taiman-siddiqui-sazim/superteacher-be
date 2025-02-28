class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.boolean :is_read, default: false
      t.timestamps
    end
  end
end
