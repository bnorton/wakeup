class AddUptimeLogs < ActiveRecord::Migration
  def change
    create_table :uptime_logs do |t|
      t.timestamps
      t.string :status
      t.datetime :pushed_at
      t.datetime :texted_at
      t.datetime :called_at
      t.integer :offset
      t.integer :pushes
      t.integer :texts
      t.integer :calls

      t.references :user
      t.references :uptime
    end
  end
end
