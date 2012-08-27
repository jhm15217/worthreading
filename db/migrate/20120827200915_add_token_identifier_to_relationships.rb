class AddTokenIdentifierToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :token_identifier, :string
  end
end
