class SeedWorker < Worker
  def perform
    seconds = Time.zone.now.utc.seconds_since_midnight.to_i

    uptimes = Uptime.where(:status => ACTIVE).
      where('"offset" >= ? AND "offset" < ?', seconds, seconds+5.minutes).pluck(:id, :offset)

    Uptime.where(:id => uptimes.map(&:first)).update_all(:status => QUEUED)

    uptimes.each do |id, offset|
      UptimePushWorker.perform_in(offset-seconds, id)
    end.each do |id, offset|
      UptimeTextWorker.perform_in(offset-seconds+2.minutes, id)
    end.each do |id, offset|
      UptimeCallWorker.perform_in(offset-seconds+4.minutes, id)
    end
  end
end
