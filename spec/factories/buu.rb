FactoryGirl.define do
  factory :buu do
    sequence(:id) {|n| n }
    name "test"
  end
end
