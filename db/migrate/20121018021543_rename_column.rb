class RenameColumn < ActiveRecord::Migration
  def up
    rename_column :wr_logs, :worth_reading, :forwarded
  end

  def down
    rename_column :wr_logs, :forwarded, :worth_reading
  end
end
