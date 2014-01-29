class SessionStartedWorker < Worker
  def perform(session_id)
    @user = (@session = Session.find(session_id)).user

    @user.touch
    alarm = @user.alarms.where(:status => [ACTIVE, STARTED]).
      where('"wake_at" < ?', Time.zone.now).first

    return unless alarm.present?

    alarm.update(:status => COMPLETED)
    @user.alarms.create(:wake_at => alarm.wake_at + 1.day)
  end
end
