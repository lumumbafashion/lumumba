FactoryGirl.define do
  factory :order_item do
    quantity 1
    size 'M'
    color 'blue'
    product
    association :order, factory: :order, strategy: :build
  end
end
