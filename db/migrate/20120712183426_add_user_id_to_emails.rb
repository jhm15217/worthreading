class AddUserIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :user_id, :integer
  end
end
