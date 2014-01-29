class Alarm < ActiveRecord::Base
  include Model

  validates :wake_at, :user_id, :presence => true

  belongs_to :user, :uptime
end
