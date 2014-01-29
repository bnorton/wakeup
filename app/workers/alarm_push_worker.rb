class AlarmPushWorker < Worker
  def perform(alarm_id)
    @user = (@alarm = Alarm.find(alarm_id)).user

    return unless can_push?

    @alarm.update(
      :status => STARTED,
      :pushed_at => Time.zone.now,
      :pushes => @alarm.pushes + 1
    )

    Push.new(@user).notify

    self.class.perform_in(20.seconds, alarm_id)
  end

  private

  def can_push?
    [ACTIVE, STARTED].include?(@alarm.status) && @alarm.pushes < 6
  end
end
