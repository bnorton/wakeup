class UptimeWorker < Worker
  def perform(uptime_id)
    @user = (@uptime = Uptime.find(uptime_id)).user

    alarm = @user.alarms.where(:status => [ACTIVE, STARTED]).
      where('"wake_at" >= ?', Time.zone.now).first

    alarm.present? && alarm.update(:status => COMPLETED)

    @user.alarms.create(@uptime.slice(:wake_at))
  end
end
