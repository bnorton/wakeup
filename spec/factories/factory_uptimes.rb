FactoryGirl.define do
  factory :uptime do
    offset { (Time.now-Time.now.midnight)+rand(60.minutes) }
  end
end
