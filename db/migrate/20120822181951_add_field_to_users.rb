class AddFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_notify, :boolean
    add_column :users, :cohort, :integer
  end
end
