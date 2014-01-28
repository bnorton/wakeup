class AddPushesTextsAndCallsToUptime < ActiveRecord::Migration
  def change
    add_column :uptimes, :pushes, :integer
    add_column :uptimes, :texts, :integer
    add_column :uptimes, :calls, :integer
  end
end
