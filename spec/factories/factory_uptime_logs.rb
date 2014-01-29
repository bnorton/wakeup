FactoryGirl.define do
  factory :uptime_log do
    wake_at Time.at(4)
    pushed_at Time.at(1)
    texted_at Time.at(2)
    called_at Time.at(3)
    pushes 3
    texts 2
    calls 1
    association(:user)
    association(:uptime)
  end
end
