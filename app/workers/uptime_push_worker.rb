class UptimePushWorker < Worker
  def perform(uptime_id, offset)
    @user, @offset = (@uptime = Uptime.find(uptime_id)).user, offset

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
    @uptime.status == ACTIVE && @uptime.pushes < 6 && @uptime.offset == @offset
  end
end
