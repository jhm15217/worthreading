class AddUrlsToWrLogs < ActiveRecord::Migration
  def change
    add_column :wr_logs, :url, :string
    add_column :wr_logs, :followed_url, :datetime
  end
end
