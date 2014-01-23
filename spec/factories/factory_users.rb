FactoryGirl.define do
  factory :user do
    sequence(:phone) {|i| "7143005#{i}#{i}" }
  end
end
