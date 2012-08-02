class RemoveRespondedFromWrLogs < ActiveRecord::Migration
  def up
    remove_column :wr_logs, :responded
  end

  def down
    add_column :wr_logs, :responded
  end
end
