module ActiveSupport
  class TimeZone
    def offset
      (now = self.now) && now - now.midnight
    end
  end
end
