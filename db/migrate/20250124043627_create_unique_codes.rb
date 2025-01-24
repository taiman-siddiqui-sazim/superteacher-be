class CreateUniqueCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :unique_codes do |t|
      t.string :email, null: false
      t.string :unique_code, null: false, limit: 6
      t.integer :attempts_left, null: false, default: 3

      t.timestamps
    end

    add_index :unique_codes, :email, unique: true
    add_index :unique_codes, :unique_code, unique: true
  end
end
