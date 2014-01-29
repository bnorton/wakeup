class Uptime < ActiveRecord::Base
  include Model

  validates :wake_at, :user_id, :presence => true

  belongs_to :user

  before_update -> { self.status = ACTIVE }, :if => :wake_at_changed?
  after_save -> { UptimeWorker.perform_async(id) }, :if => :wake_at_changed?
end
