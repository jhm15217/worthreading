class AddSubscribersToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :subscriber_id, :integer
    add_column :relationships, :subscribed_id, :integer

    remove_column :relationships, :follower_id
    remove_column :relationships, :followed_id

    add_index :relationships, :subscriber_id
    add_index :relationships, :subscribed_id
    add_index :relationships, [:subscribed_id, :subscriber_id], unique: true
  end
end
