class AddExtrasV1ToUsers < ActiveRecord::Migration
  def change
    add_column :users, :udid, :string
    add_column :users, :bundle, :string
  end
end
