class UptimeTextWorker < Worker
  def perform(uptime_id, offset)
    @user, @offset = (@uptime = Uptime.find(uptime_id)).user, offset

    return unless can_text?

    @uptime.update(
      :status => STARTED,
      :texted_at => Time.zone.now,
      :texts => @uptime.texts + 1
    )

    Messaging.new(@user).text('no really wake up')

    self.class.perform_in(30.seconds, uptime_id)
  end

  private

  def can_text?
    @uptime.status == ACTIVE && @uptime.texts < 2 && @uptime.offset == @offset
  end
end
