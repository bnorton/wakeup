class AddStatusToUserAndUptime < ActiveRecord::Migration
  def change
    add_column :users,   :status, :string
    add_column :uptimes, :status, :string
  end
end
