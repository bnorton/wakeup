class UptimePushWorker < Worker
  def perform(uptime_id)
    @user = (@uptime = Uptime.find(uptime_id)).user

    return unless can_push?

    @uptime.update(
      :status => STARTED,
      :pushed_at => Time.zone.now,
      :pushes => @uptime.pushes + 1
    )

    Push.new(@user).notify

    self.class.perform_in(20.seconds, uptime_id)
  end

  private

  def can_push?
    @uptime.status == ACTIVE && @uptime.pushes < 6
  end
end
