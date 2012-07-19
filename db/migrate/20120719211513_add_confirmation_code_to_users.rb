class AddConfirmationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_token, :integer
  end
end
