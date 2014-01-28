class SeedWorker < Worker
  def perform
    uptimes = Uptime.where(:status => ACTIVE).
      where('"offset" >= ? AND "offset" < ?', seconds-1.minute, seconds+5.minutes).pluck(:id, :offset)

    Uptime.where(:id => uptimes.map(&:first)).update_all(:status => QUEUED)

    uptimes.each do |id, offset|
      UptimePushWorker.perform_in(offset-seconds, id)
    end.each do |id, offset|
      UptimeTextWorker.perform_in(offset-seconds+2.minutes, id)
    end.each do |id, offset|
      UptimeCallWorker.perform_in(offset-seconds+4.minutes, id)
    end
  end

  def seconds
    @seconds ||= Time.zone.now.seconds_since_midnight.to_i
  end
end
