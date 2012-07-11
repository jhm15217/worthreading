class AddLikesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :likes, :integer
  end
end
