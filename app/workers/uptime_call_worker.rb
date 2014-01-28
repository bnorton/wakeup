class UptimeCallWorker < Worker
  def perform(uptime_id, offset)
    @user, @offset = (@uptime = Uptime.find(uptime_id)).user, offset

    return unless can_call?

    @uptime.update(
      :status => STARTED,
      :called_at => Time.zone.now,
      :calls => @uptime.calls + 1
    )

    Messaging.new(@user).call

    self.class.perform_in(60.seconds, uptime_id)
  end

  private

  def can_call?
    @uptime.status == ACTIVE && @uptime.calls < 4 && @uptime.offset == @offset
  end
end
