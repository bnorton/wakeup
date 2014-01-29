class AlarmCallWorker < Worker
  def perform(alarm_id)
    @user = (@alarm = Alarm.find(alarm_id)).user

    return unless can_call?

    @alarm.update(
      :called_at => Time.zone.now,
      :calls => @alarm.calls + 1
    )

    Messaging.new(@user).call

    self.class.perform_in(60.seconds, alarm_id)
  end

  private

  def can_call?
    @alarm.status == STARTED && @alarm.calls < 4
  end
end
