class Uptime < ActiveRecord::Base
  include Model

  validates :offset, :presence => true

  belongs_to :user

  before_update -> { self.status = ACTIVE }, :if => :offset_changed?
  after_update :completion, :if  => :completion?

  private

  def completion
    offset < Time.zone.offset ? UptimeCompletedWorker.perform_async(id, offset) :
      UptimeCompletedWorker.perform_in(10.minutes, id, offset)
  end

  def completion?
    status_changed? && status == COMPLETED
  end
end
