class DeleteForwardFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :forward
  end

  def down
    add_column :users, :forward
  end
end
