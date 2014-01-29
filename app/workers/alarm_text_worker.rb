class AlarmTextWorker < Worker
  def perform(alarm_id)
    @user = (@alarm = Alarm.find(alarm_id)).user

    return unless can_text?

    @alarm.update(
      :texted_at => Time.zone.now,
      :texts => @alarm.texts + 1
    )

    Messaging.new(@user).text('no really wake up')

    self.class.perform_in(30.seconds, alarm_id)
  end

  private

  def can_text?
    @alarm.status == STARTED && @alarm.texts < 2
  end
end
