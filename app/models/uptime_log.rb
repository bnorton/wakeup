class UptimeLog < ActiveRecord::Base
  include Model

  validates :offset, :pushed_at, :texted_at, :called_at, :pushes, :texts, :calls, :presence => true
  validates :user_id, :uptime_id, :presence => true

  belongs_to :user, :uptime
end
