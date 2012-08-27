class AddForwardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forward, :boolean
  end
end
