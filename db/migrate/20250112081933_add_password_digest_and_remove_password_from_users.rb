class AddPasswordDigestAndRemovePasswordFromUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_digest, :string
    remove_column :users, :password, :string
  end
end
