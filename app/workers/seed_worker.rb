class SeedWorker < Worker
  def perform
    als = Alarm.where(:status => ACTIVE).
      where('"wake_at" < ?', 5.minutes.from_now).pluck(:id, :wake_at)

    Alarm.where(:id => als.map(&:first)).update_all(:status => QUEUED)

    als.each do |id, wake_at|
      AlarmPushWorker.perform_at(wake_at, id)
    end.each do |id, wake_at|
      AlarmTextWorker.perform_at(wake_at+2.minutes, id)
    end.each do |id, wake_at|
      AlarmCallWorker.perform_at(wake_at+4.minutes, id)
    end
  end
end
