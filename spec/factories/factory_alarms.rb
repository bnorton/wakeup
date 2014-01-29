FactoryGirl.define do
  factory :alarm do
    wake_at { rand(60).minutes.from_now }
    association(:user)
    association(:uptime)
  end
end
