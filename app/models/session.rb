class Session < ActiveRecord::Base
  include Model

  validates :started_at, :user_id, :presence => true

  belongs_to :user

  before_update -> { self.status = COMPLETED }, :if => :ended_at_changed?
  after_create  -> { SessionStartedWorker.perform_async(id) }
end
