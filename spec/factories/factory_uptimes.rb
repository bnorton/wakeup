FactoryGirl.define do
  factory :uptime do
    wake_at { rand(60).minutes.from_now }
    association(:user)
  end
end
