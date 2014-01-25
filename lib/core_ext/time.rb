class Time
  def iso
    self.utc.strftime('%Y-%m-%dT%H:%I:%S.%LZ')
  end
end
