FactoryGirl.define do
  factory :order do
    order_number { SecureRandom.hex }
    payment_method { SecureRandom.hex }
    total_amount 1.50
    status { Order::OPEN }
    user
  end
end
