class AddUptimes < ActiveRecord::Migration
  def change
    create_table :uptimes do |t|
      t.timestamps
      t.integer :offset
      t.timestamp :pushed_at
      t.timestamp :texted_at
      t.timestamp :called_at

      t.references :user
    end

    add_index :uptimes, :user_id, :unique => true
    add_index :uptimes, :offset
  end
end
