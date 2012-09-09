class AddPartsToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :parts, :text
  end
end
