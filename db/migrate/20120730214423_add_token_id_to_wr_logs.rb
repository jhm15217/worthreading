class AddTokenIdToWrLogs < ActiveRecord::Migration
  def change
    add_column :wr_logs, :token_identifier, :string
  end
end
