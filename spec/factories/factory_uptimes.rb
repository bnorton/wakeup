FactoryGirl.define do
  factory :uptime do
    offset { (Time.zone.now-Time.zone.now.midnight)+rand(60.minutes) }
  end
end
