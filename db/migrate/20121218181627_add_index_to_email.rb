class AddIndexToEmail < ActiveRecord::Migration
  def change
    add_index(:emails, [:to, :body], unique: true)
  end
end
