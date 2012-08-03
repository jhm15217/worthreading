class AddPasswordResetSentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_sent, :datetime
  end
end
