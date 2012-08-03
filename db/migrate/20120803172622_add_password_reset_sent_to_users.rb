class AddPasswordResetSentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_sent_at, :datetime
    add_index :users, :confirmation_token
  end
end
