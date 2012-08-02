class AddTimersToWrLogs < ActiveRecord::Migration
  def change
    add_column :wr_logs, :emailed, :datetime
    add_column :wr_logs, :opened, :datetime
    add_column :wr_logs, :worth_reading, :datetime
  end
end
