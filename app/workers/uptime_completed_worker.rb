class UptimeCompletedWorker < Worker
  def perform(uptime_id)
    @user = (@uptime = Uptime.find(uptime_id)).user

    return unless can_activate?

    @uptime.update( :status => ACTIVE )
    @user.uptime_logs.create(attributes)
  end

  private

  def can_activate?
    @uptime.status == COMPLETED
  end

  def attributes
    @uptime.slice(:offset, :pushed_at, :texted_at, :called_at, :pushes, :texts, :calls, :id => :uptime_id)
  end
end
