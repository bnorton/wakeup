class Uptime < ActiveRecord::Base
  include Model

  validates :offset, :presence => true

  belongs_to :user

  after_save :completion, :if  => :completion?

  private

  def completion
    offset < Time.zone.offset ? UptimeCompletedWorker.perform_async(id) :
      UptimeCompletedWorker.perform_in(10.minutes, id)
  end

  def completion?
    status_changed? && status == COMPLETED
  end
end
