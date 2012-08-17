class AddFirstLoginAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_login_at, :datetime
  end
end
