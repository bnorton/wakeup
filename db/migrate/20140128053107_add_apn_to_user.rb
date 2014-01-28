class AddApnToUser < ActiveRecord::Migration
  def change
    add_column :users, :apn, :string
    add_column :users, :apn_at, :datetime
  end
end
