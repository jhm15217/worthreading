class CreateWrLogs < ActiveRecord::Migration
  def change
    create_table :wr_logs do |t|
      t.string :action
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :email_id
      t.integer :email_part
      t.boolean :responded

      t.timestamps
    end
  end
end
