class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.timestamps
      t.string   :phone
      t.string   :token
      t.string   :locale
      t.string   :version
      t.integer  :code
      t.integer  :vcode
      t.integer  :timezone
      t.datetime :verified_at
    end

    add_index :users, :phone, :unique => true
  end
end
