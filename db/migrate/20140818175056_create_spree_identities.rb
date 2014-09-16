class CreateSpreeIdentities < ActiveRecord::Migration
  def change
    create_table :spree_identities do |t|
      t.references :spree_user, index: true
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
