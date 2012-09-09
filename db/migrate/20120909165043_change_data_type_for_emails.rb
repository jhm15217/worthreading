class ChangeDataTypeForEmails < ActiveRecord::Migration
  def up
    change_column :emails, :parts, :text
  end

  def down
    change_column :emails, :parts, :string
  end
end
