class AddFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_notify, :boolean { default: true }
    add_column :users, :cohort, :integer {default: 0 }
  end
end
