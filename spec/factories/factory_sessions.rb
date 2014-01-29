FactoryGirl.define do
  factory :session do
    started_at { Time.zone.now }
    association(:user)
  end
end
