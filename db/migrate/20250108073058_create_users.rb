class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :gender, null: false
      t.string :email, null: false
      t.string :password, null: false
      t.string :user_type, null: false

      t.timestamps
    end

    add_check_constraint :users, "user_type IN ('student', 'teacher')", name: 'user_type_check'
  end
end
